import pandas as pd
import numpy as np
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
import gc
import os
import time
import warnings
from itertools import combinations
from warnings import simplefilter

import joblib
import lightgbm as lgb
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import KFold, TimeSeriesSplit
import polars as pl
from sklearn.preprocessing import MinMaxScaler, StandardScaler, OneHotEncoder
from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
warnings.filterwarnings("ignore")
simplefilter(action="ignore", category=pd.errors.PerformanceWarning)

# is_offline = True
# is_train = True
# is_infer = True
# max_lookback = np.nan
# split_day = 435

import seaborn as sns
import matplotlib.pyplot as plt
from catboost import CatBoostRegressor, EShapCalcType, EFeaturesSelectionAlgorithm
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split
from sklearn.impute import KNNImputer
from sklearn.metrics import r2_score, mean_absolute_error

file_path = 'all_features_filled.csv'
data = pd.read_csv(file_path)

na_counts = data.isna().sum()

data = data.drop(columns=['Unnamed: 0', 'Target_rate_discounted'])

stock_list = np.unique(data.sp_Symbol)

data_list = []
for s in stock_list:
    data_list.append(data.loc[data.sp_Symbol==s, :].fillna(method='ffill'))

data = pd.concat(data_list)

date_list = np.unique(data.sp_Date)
date_flag = 1
data['date_id'] = 0
for d in date_list:
    data.loc[data.sp_Date==d, 'date_id'] = date_flag
    date_flag += 1


non_numeric_col_list = []
for c in data.columns:
    try:
        data.loc[:, c] = pd.to_numeric(data.loc[:, c]).values
    except:
        non_numeric_col_list.append(c)

non_numeric_col_list.extend(['GICS_id', 'sp_Industry', 'fs_Industry', 'Month', 'Year', 'date_id', 'sp_1d_rt'])

# data = data.drop(non_numeric_col_list, axis=1)
feature_name = [i for i in data.columns if i not in non_numeric_col_list]

data['sp_1d_rt_positive'] = [int(i>=0) for i in data['sp_1d_rt']]


# imp = IterativeImputer(max_iter=10, random_state=0)
# data_fill_np = imp.fit_transform(data)

knn_imputer = KNNImputer(n_neighbors=2, weights="uniform")
data_fill_np = knn_imputer.fit_transform(data[feature_name])

data_fill = pd.DataFrame(data_fill_np, columns=feature_name)

std_scaler = StandardScaler()
data_std_np = std_scaler.fit_transform(data_fill)

data_std = pd.DataFrame(data_std_np, columns=feature_name)
data_std['date_id'] = data['date_id']
data_std['sp_1d_rt_positive'] = data['sp_1d_rt_positive']

index_start = np.where(np.asarray(data_std.columns)=='Tax_Effect_Of_Unusual_Items')[0][0]
index_end = np.where(np.asarray(data_std.columns)=='Net_Income_From_Continuing_Operations')[0][0]

data_std = data_std.drop(data_std.columns[index_start: index_end+1], axis=1)

# na_counts = data_fill.isna().sum()

# X = data_std.drop(['sp_1d_rt'], axis=1)
# y = data_std.sp_1d_rt

split_id = 797 - 150
test_df = data_std.loc[data_std.date_id > split_id, :].reset_index(drop=True)
train_df = data_std.loc[data_std.date_id <= split_id, :].reset_index(drop=True)

date_ids_tscv = np.unique(train_df['date_id'].values)
date_ids = train_df['date_id'].values

tscv = TimeSeriesSplit(n_splits = 5)
spliteed = tscv.split(date_ids_tscv)

target = 'sp_1d_rt_positive'
catboost_sumary_list = []



N = 15
for i, (train_index, test_index) in enumerate(spliteed):
    #Define start days and end days of training and validation sets
    train_indices = (date_ids >= train_index[0]) & (date_ids <= train_index[-1])
    test_indices = (date_ids >= test_index[0]) & (date_ids <= test_index[-1])
        
    # Create fold-specific training and validation sets
    df_fold_train = train_df[train_indices].drop(['date_id', target], axis=1)
    df_fold_train_target = train_df[target][train_indices]
    df_fold_valid = train_df[test_indices].drop(['date_id', target], axis=1)
    df_fold_valid_target = train_df[target][test_indices]




# from sklearn.ensemble import ExtraTreesClassifier
# from sklearn.datasets import load_iris
# from sklearn.feature_selection import SelectFromModel

# clf = ExtraTreesClassifier(n_estimators=50)
# clf = clf.fit(X_train, y_train)
# clf.feature_importances_  
# model = SelectFromModel(clf, prefit=True)
# X_new = model.transform(X)
# X_new.shape               

    
    # Train procedure    
    ctb_params = dict(iterations=1200,
                      learning_rate=1.0,
                      depth=8,
                      l2_leaf_reg=30,
                      bootstrap_type='Bernoulli',
                      subsample=0.66,
                      loss_function='MultiRMSE',
                      eval_metric = 'MultiRMSE',
                      metric_period=100,
                      od_type='Iter',
                      od_wait=30,
                      task_type='CPU',
                      allow_writing_files=False,
                      )
        
    print("Feature Elimination Performing.")
    ctb_model = CatBoostRegressor(**ctb_params)
    summary = ctb_model.select_features(
        df_fold_train, df_fold_train_target,
        eval_set=[(df_fold_valid, df_fold_valid_target)],
        features_for_select=df_fold_train.columns,
        num_features_to_select=N,    # Dropping from 124 to 100
        steps=3,
        algorithm=EFeaturesSelectionAlgorithm.RecursiveByShapValues,
        shap_calc_type=EShapCalcType.Regular,
        train_final_model=False,
        plot=True
    )
    catboost_sumary_list.append(summary)
    
# print("Valid Model Training on Selected Features Subset.")
# ctb_model = CatBoostRegressor(**ctb_params)
# ctb_model.fit(
#     X_train[summary['selected_features_names']], X_train,
#     eval_set=[(X_valid[summary['selected_features_names']], y_valid)],
#     use_best_model=True,
# )
    
    
# print("Infer Model Training on Selected Features Subset.")
# infer_params = ctb_params.copy()
# # CatBoost train best with Valid number of iterations
# infer_params["iterations"] = ctb_model.best_iteration_
# infer_ctb_model = CatBoostRegressor(**infer_params)
# infer_ctb_model.fit(X_train[summary['selected_features_names']], y_train)
# print("Infer Model Training on Selected Features Subset Complete.")
    
# if is_offline:   
#     # Offline predictions
#     df_valid_target = df_valid["target"]
#     offline_predictions = infer_ctb_model.predict(df_valid_feats[summary['selected_features_names']])
#     offline_score = mean_absolute_error(offline_predictions, df_valid_target)
#     print(f"Offline Score {np.round(offline_score, 4)}")
#     del df_valid, df_valid_feats
#     gc.collect()

# del df_train_feats
# gc.collect()

best_rmse = 1
best_rmse_index = 0
for c in range(len(catboost_sumary_list)):
    summary_temp = catboost_sumary_list[c]
    rmse_temp = min(summary_temp['loss_graph']['loss_values'])
    if rmse_temp < best_rmse:
        best_rmse = rmse_temp
        best_rmse_index = c

loss_graph = catboost_sumary_list[best_rmse_index]['loss_graph']
loss_values = loss_graph['loss_values']
main_indices = loss_graph['main_indices']
removed_features_count = loss_graph['removed_features_count']

loss_data = pd.DataFrame({'loss_values':loss_values,
              'removed_features_count':removed_features_count})

# Adding specific points to the graph in red
highlighted_points = main_indices

# Re-plotting with highlighted points
plt.figure(figsize=(10, 6))
plt.plot(loss_data['removed_features_count'], loss_data['loss_values'], marker='o', linestyle='-', color='lightsteelblue', label='Loss Value Curve')
plt.scatter(highlighted_points, loss_data.loc[loss_data['removed_features_count'].isin(highlighted_points), 'loss_values'], color='lightcoral', marker='o', zorder=20, label='Highlighted Points')
plt.title(r'N = %d' % N)
plt.xlabel('Number of Removed Features')
plt.ylabel('Loss Value')
plt.grid(True)
plt.legend()
plt.show()


feature_name = catboost_sumary_list[best_rmse_index]['selected_features_names']

pd.DataFrame({'loss_values':loss_values,
              'removed_features_count':removed_features_count}).to_csv('loss_value.csv', index=False)


# Set LightGBM parameters
lgb_params = {
    "objective": "mae",
    "n_estimators": 5000, #less estimators
    "num_leaves": 256, #more leaves
    "subsample": 0.6,
    "colsample_bytree": 0.6,
    "learning_rate": 0.00871, #larger learning rate(from 0.00871 to 0.00005)
    'max_depth': 11,
    "n_jobs": 4,
    "device": "gpu",
    "verbosity": -1,
    "importance_type": "gain",
}

# Initialize lists to store models and scores
models = []
scores = []

# Set model save path
model_save_path = 'modelitos_para_despues'
if not os.path.exists(model_save_path):
    os.makedirs(model_save_path)

# Get date IDs from the training data
date_ids_tscv = np.unique(train_df['date_id'].values)
date_ids = train_df['date_id'].values

tscv = TimeSeriesSplit(n_splits = 5)
spliteed = tscv.split(date_ids_tscv)


# Loop over folds for cross-validation
for i, (train_index, test_index) in enumerate(spliteed):
    #Define start days and end days of training and validation sets
    train_indices = (date_ids >= train_index[0]) & (date_ids <= train_index[-1])
    test_indices = (date_ids >= test_index[0]) & (date_ids <= test_index[-1])
        
    # Create fold-specific training and validation sets
    df_fold_train = train_df[train_indices].drop(['date_id', target], axis=1)
    df_fold_train_target = train_df[target][train_indices]
    df_fold_valid = train_df[test_indices].drop(['date_id', target], axis=1)
    df_fold_valid_target = train_df[target][test_indices]
    
    print(f"Fold {i+1} Model Training")
    
    # Train a LightGBM model for the current fold
    lgb_model = lgb.LGBMRegressor(**lgb_params)
    lgb_model.fit(
        df_fold_train[feature_name],
        df_fold_train_target,
        eval_set=[(df_fold_valid[feature_name], df_fold_valid_target)],
        callbacks=[
            lgb.callback.early_stopping(stopping_rounds=100),
            lgb.callback.log_evaluation(period=100),
        ],
    )

    models.append(lgb_model)

    # Save the model to a file
    model_filename = os.path.join(model_save_path, f'doblez_{i+1}.txt')
    lgb_model.booster_.save_model(model_filename)
    print(f"Model for fold {i+1} saved to {model_filename}")

    # Evaluate model performance on the validation set
    fold_predictions = lgb_model.predict(df_fold_valid[feature_name])
    fold_score = mean_absolute_error(fold_predictions, df_fold_valid_target)
    scores.append(fold_score)
    print(f"Fold {i+1} MAE: {fold_score}")

    # Free up memory by deleting fold-specific variables
    del df_fold_train, df_fold_train_target, df_fold_valid, df_fold_valid_target
    gc.collect()

# Calculate the average best iteration from all regular folds
average_best_iteration = int(np.mean([model.best_iteration_ for model in models]))

# Update the lgb_params with the average best iteration
final_model_params = lgb_params.copy()
final_model_params['n_estimators'] = average_best_iteration

print(f"Training final model with average best iteration: {average_best_iteration}")

# Train the final model on the entire dataset
final_model = lgb.LGBMRegressor(**final_model_params)
final_model.fit(
    train_df[feature_name],
    train_df[target],
    callbacks=[
        lgb.callback.log_evaluation(period=100),
    ],
)
# Append the final model to the list of models
models.append(final_model)

# Append the final model to the list of models
models.append(final_model)

# Save the final model to a file
final_model_filename = os.path.join(model_save_path, 'doblez-conjunto.txt')
final_model.booster_.save_model(final_model_filename)
print(f"Final model saved to {final_model_filename}")

# Now 'models' holds the trained models for each fold and 'scores' holds the validation scores
print(f"Average MAE across all folds: {np.mean(scores)}")

y_predict = final_model.predict(test_df[feature_name])

from sklearn.metrics import root_mean_squared_error

y_test = test_df[target]

print('\n')
print('test set RMSE: %f' % root_mean_squared_error(y_predict, y_test))
print('test set MAE: %f' % mean_absolute_error(y_test, y_predict))



# if is_offline:
#     # offline predictions
#     df_valid_target = df_valid["target"]
#     offline_predictions = final_model.predict(df_valid_feats[feature_name])
#     offline_score = mean_absolute_error(offline_predictions, df_valid_target)
#     print(f"Offline Score {np.round(offline_score, 4)}")

