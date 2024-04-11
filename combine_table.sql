-- 股票：stock_price_features和financial_statement_features合并
    -- finiancial_statement_features：年度
-- 行业：
    -- industry_summary_daily (GICS_id,Date)
    -- monthly Month,
    -- yearly 选取最近三年有统一度量的行业数据
-- 一个宏观指标的表 macro_index
    -- 月度
-- step1. 合并表格 
-- step2. 筛选不必要的年份

CREATE TABLE combined_table_1 AS
(
SELECT
    sp.`Date` AS sp_Date,
    fs.`Date` AS fs_Date,
    ind.`Date` AS ind_Date,
    m.`Date` AS m_Date,
    fs.`Symbol` AS fs_Symbol,
    sp.`Symbol` AS sp_Symbol,
    ind.`GICS_id`,
    sp.`Industry` AS sp_Industry,
    sp.`Open` AS sp_Open,
    sp.`High` AS sp_High,
    sp.`Low` AS sp_Low,
    sp.`Close` AS sp_Close,
    sp.`Adj_Close` AS sp_Adj_Close,
    sp.`Volume` AS sp_Volume,
    sp.`1d_rt` AS sp_1d_rt,
    sp.`5d_rt` AS sp_5d_rt,
    sp.`22d_rt` AS sp_22d_rt,
    sp.`stock_5d_MA` AS sp_stock_5d_MA,
    sp.`stock_22d_MA` AS sp_stock_22d_MA,
    sp.`vol_1d_pct` AS sp_vol_1d_pct,
    sp.`vol_5d_pct` AS sp_vol_5d_pct,
    sp.`vol_22d_pct` AS sp_vol_22d_pct,
    sp.`vol_5d_MA` AS sp_vol_5d_MA,
    sp.`vol_22d_MA` AS sp_vol_22d_MA,
    sp.`stock_5d_std` AS sp_stock_5d_std,
    sp.`stock_22d_std` AS sp_stock_22d_std,
    sp.`vol_5d_std` AS sp_vol_5d_std,
    sp.`vol_22d_std` AS sp_vol_22d_std,
    sp.`search_popularity` AS sp_search_popularity,
    sp.`ESG_score` AS sp_ESG_score,
    sp.`E_score` AS sp_E_score,
    sp.`S_score` AS sp_S_score,
    sp.`G_score` AS sp_G_score,
    sp.`Sentiment_scores` AS sp_Sentiment_scores,
    fs.`Industry` AS fs_Industry,
    fs.`Tax_Effect_Of_Unusual_Items`,
    fs.`Tax_Rate_For_Calcs`,
    fs.`Net_Income_From_Continuing_Operation_Net_Minority_Interest`,
    fs.`Reconciled_Depreciation`,
    fs.`Net_Interest_Income`,
    fs.`Interest_Expense`,
    fs.`Normalized_Income`,
    fs.`Net_Income_From_Continuing_And_Discontinued_Operation`,
    fs.`Diluted_NI_Availto_Com_Stockholders`,
    fs.`Net_Income_Common_Stockholders`,
    fs.`Net_Income`,
    fs.`Net_Income_Including_Noncontrolling_Interests`,
    fs.`Net_Income_Continuous_Operations`,
    fs.`Tax_Provision`,
    fs.`Pretax_Income`,
    fs.`Total_Revenue`,
    fs.`Operating_Revenue`,
    fs.`Ordinary_Shares_Number`,
    fs.`Share_Issued`,
    fs.`Total_Debt`,
    fs.`Tangible_Book_Value`,
    fs.`Invested_Capital`,
    fs.`Net_Tangible_Assets`,
    fs.`Common_Stock_Equity`,
    fs.`Total_Capitalization`,
    fs.`Total_Equity_Gross_Minority_Interest`,
    fs.`Stockholders_Equity`,
    fs.`Gains_Losses_Not_Affecting_Retained_Earnings`,
    fs.`Retained_Earnings`,
    fs.`Capital_Stock`,
    fs.`Common_Stock`,
    fs.`Total_Liabilities_Net_Minority_Interest`,
    fs.`Long_Term_Debt_And_Capital_Lease_Obligation`,
    fs.`Long_Term_Debt`,
    fs.`Payables_And_Accrued_Expenses`,
    fs.`Total_Assets`,
    fs.`Net_PPE`,
    fs.`Receivables`,
    fs.`Accounts_Receivable`,
    fs.`Cash_And_Cash_Equivalents`,
    fs.`Free_Cash_Flow`,
    fs.`Repayment_Of_Debt`,
    fs.`End_Cash_Position`,
    fs.`Beginning_Cash_Position`,
    fs.`Changes_In_Cash`,
    fs.`Financing_Cash_Flow`,
    fs.`Cash_Flow_From_Continuing_Financing_Activities`,
    fs.`Net_Issuance_Payments_Of_Debt`,
    fs.`Net_Long_Term_Debt_Issuance`,
    fs.`Long_Term_Debt_Payments`,
    fs.`Investing_Cash_Flow`,
    fs.`Cash_Flow_From_Continuing_Investing_Activities`,
    fs.`Operating_Cash_Flow`,
    fs.`Cash_Flow_From_Continuing_Operating_Activities`,
    fs.`Change_In_Working_Capital`,
    fs.`Change_In_Receivables`,
    fs.`Net_Income_From_Continuing_Operations`,
    fs.`Net_Profit_Margin`,
    fs.`Capital_Structure_Ratio`,
    fs.`Equity_Ratio`,
    fs.`Cash_Liquidity_Ratio`,
    fs.`Accounts_Recievable_Turnover`,
    fs.`Total_Assets_Turnover`,
    fs.`Financial_Leverage`,
    fs.`PCA_C0`,
    fs.`PCA_C1`,
    fs.`PCA_C2`,
    fs.`PCA_C3`,
    fs.`PCA_C4`,
    fs.`PCA_C5`,
    fs.`PCA_C6`,
    fs.`PCA_C7`,
    fs.`PCA_C8`,
    fs.`PCA_C9`,
    ind.`ETF_Type`,
    ind.`ETF_5dMA`,
    ind.`ETF_22dMA`,
    ind.`ETF_5dstd`,
    ind.`ETF_22std`,
    ind.`1d_rt` AS ind_1d_rt,
    ind.`5d_rt` AS ind_5d_rt,
    ind.`22d_rt` AS ind_22d_rt,
    ind.`Vol_5dMA`,
    ind.`Vol_22dMA`,
    ind.`Vol_1d_pct`,
    ind.`Vol_5d_pct`,
    ind.`Vol_5dstd`,
    ind.`Vol_22dstd`,
    m.CPI,
    m.CPI_YoY,
    m.Core_CPI,
    m.Core_CPI_YoY,
    m.PPI,
    m.PPI_YoY,
    m.Retailers_Inventories_Sales_Ratio,
    m.Retailers_YoY,
    m.Total_Buz_Inventories_Sales_Ratio,
    m.Total_Buz_YoY,
    m.Unemployment_Rate,
    m.Target_rate_discounted,
    m.Target_range_upper_limit,
    m.Target_range_louwer_limit,
    m.CPI_QoQ,
    m.Core_CPI_QoQ,
    m.PPI_QoQ,
    m.Retailers_Inventories_Sales_Ratio_QoQ,
    m.Total_Buz_Inventories_Sales_Ratio_QoQ,
    m.Unemployment_Rate_QoQ
FROM stock_price_features sp
LEFT JOIN financial_statement_features fs ON YEAR(sp.`Date`) = YEAR(fs.`Date`) AND sp.`Symbol` = fs.`Symbol`
LEFT JOIN industry_summary_daily ind ON sp.`Industry` = ind.`GICS_id` AND DATE(sp.`Date`) = DATE(ind.`Date`)
LEFT JOIN macro_index m ON DATE_FORMAT(sp.`Date`,'%Y%m') = DATE_FORMAT(m.Date,'%Y%m')
)


SELECT * 
FROM combined_table_1
WHERE YEAR(sp_Date) >= 2020
limit 100;


SHOW CREATE TABLE industry_summary_yearly;

DROP TABLE temp_Profit_Rate_Index;
-- 创建一个临时表存储转换后的数据
CREATE TABLE temp_Growth_Rate_Index AS
SELECT 'Communication_Services_Growth_Rate_Index' AS category, '2021' AS year, `Communication_Services_Growth_Rate_Index` AS value FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Communication_Services_Growth_Rate_Index', '2022', `Communication_Services_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Communication_Services_Growth_Rate_Index', '2023', `Communication_Services_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Consumer_Discretionary_Growth_Rate_Index', '2021', `Consumer_Discretionary_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Consumer_Discretionary_Growth_Rate_Index', '2022', `Consumer_Discretionary_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Consumer_Discretionary_Growth_Rate_Index', '2023', `Consumer_Discretionary_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Consumer_Staples_Growth_Rate_Index', '2021', `Consumer_Staples_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Consumer_Staples_Growth_Rate_Index', '2022', `Consumer_Staples_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Consumer_Staples_Growth_Rate_Index', '2023', `Consumer_Staples_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Energy_Growth_Rate_Index', '2021', `Energy_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Energy_Growth_Rate_Index', '2022', `Energy_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Energy_Growth_Rate_Index', '2023', `Energy_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Financials_Growth_Rate_Index', '2021', `Financials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Financials_Growth_Rate_Index', '2022', `Financials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Financials_Growth_Rate_Index', '2023', `Financials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Health_Care_Growth_Rate_Index', '2021', `Health_Care_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Health_Care_Growth_Rate_Index', '2022', `Health_Care_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Health_Care_Growth_Rate_Index', '2023', `Health_Care_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Industrials_Growth_Rate_Index', '2021', `Industrials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Industrials_Growth_Rate_Index', '2022', `Industrials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Industrials_Growth_Rate_Index', '2023', `Industrials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Information_Technology_Growth_Rate_Index', '2021', `Information_Technology_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Information_Technology_Growth_Rate_Index', '2022', `Information_Technology_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Information_Technology_Growth_Rate_Index', '2023', `Information_Technology_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Materials_Growth_Rate_Index', '2021', `Materials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Materials_Growth_Rate_Index', '2022', `Materials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Materials_Growth_Rate_Index', '2023', `Materials_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Real_Estate_Growth_Rate_Index', '2021', `Real_Estate_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Real_Estate_Growth_Rate_Index', '2022', `Real_Estate_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Real_Estate_Growth_Rate_Index', '2023', `Real_Estate_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Utilities_Growth_Rate_Index', '2021', `Utilities_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Utilities_Growth_Rate_Index', '2022', `Utilities_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Utilities_Growth_Rate_Index', '2023', `Utilities_Growth_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023;




CREATE TABLE temp_Profit_Rate_Index AS
SELECT 'Communication_Services_Profit_Rate_Index' AS category, '2021' AS year, `Communication_Services_Profit_Rate_Index` AS value FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Communication_Services_Profit_Rate_Index', '2022', `Communication_Services_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Communication_Services_Profit_Rate_Index', '2023', `Communication_Services_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Consumer_Discretionary_Profit_Rate_Index', '2021', `Consumer_Discretionary_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Consumer_Discretionary_Profit_Rate_Index', '2022', `Consumer_Discretionary_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Consumer_Discretionary_Profit_Rate_Index', '2023', `Consumer_Discretionary_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Consumer_Staples_Profit_Rate_Index', '2021', `Consumer_Staples_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Consumer_Staples_Profit_Rate_Index', '2022', `Consumer_Staples_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Consumer_Staples_Profit_Rate_Index', '2023', `Consumer_Staples_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Energy_Profit_Rate_Index', '2021', `Energy_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Energy_Profit_Rate_Index', '2022', `Energy_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Energy_Profit_Rate_Index', '2023', `Energy_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Financials_Profit_Rate_Index', '2021', `Financials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Financials_Profit_Rate_Index', '2022', `Financials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Financials_Profit_Rate_Index', '2023', `Financials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Health_Care_Profit_Rate_Index', '2021', `Health_Care_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Health_Care_Profit_Rate_Index', '2022', `Health_Care_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Health_Care_Profit_Rate_Index', '2023', `Health_Care_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Industrials_Profit_Rate_Index', '2021', `Industrials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Industrials_Profit_Rate_Index', '2022', `Industrials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Industrials_Profit_Rate_Index', '2023', `Industrials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Information_Technology_Profit_Rate_Index', '2021', `Information_Technology_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Information_Technology_Profit_Rate_Index', '2022', `Information_Technology_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Information_Technology_Profit_Rate_Index', '2023', `Information_Technology_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Materials_Profit_Rate_Index', '2021', `Materials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Materials_Profit_Rate_Index', '2022', `Materials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Materials_Profit_Rate_Index', '2023', `Materials_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Real_Estate_Profit_Rate_Index', '2021', `Real_Estate_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Real_Estate_Profit_Rate_Index', '2022', `Real_Estate_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Real_Estate_Profit_Rate_Index', '2023', `Real_Estate_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023
UNION ALL
SELECT 'Utilities_Profit_Rate_Index', '2021', `Utilities_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2021
UNION ALL
SELECT 'Utilities_Profit_Rate_Index', '2022', `Utilities_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2022
UNION ALL
SELECT 'Utilities_Profit_Rate_Index', '2023', `Utilities_Profit_Rate_Index` FROM industry_summary_yearly
WHERE date = 2023;

CREATE TABLE temp_Growth_Rate_Index_GICS AS
SELECT t.*,GICS_id 
FROM temp_Growth_Rate_Index t 
LEFT JOIN industry_index_summary i
ON t.category COLLATE utf8mb4_unicode_ci = i.index_name COLLATE utf8mb4_unicode_ci;

CREATE TABLE temp_Profit_Rate_Index_GICS AS
SELECT t.*,GICS_id 
FROM temp_Profit_Rate_Index t 
LEFT JOIN industry_index_summary i
ON t.category COLLATE utf8mb4_unicode_ci = i.index_name COLLATE utf8mb4_unicode_ci;

-- 添加 Growth_Rate_Index 和 Profit_Rate_Index 列到 combined_table_1
ALTER TABLE combined_table_1
ADD COLUMN Growth_Rate_Index VARCHAR(255), -- 你可以根据需要指定适当的数据类型和长度
ADD COLUMN Growth_Rate_Index_Value DOUBLE,
ADD COLUMN Profit_Rate_Index VARCHAR(255),
ADD COLUMN Profit_Rate_Index_Value DOUBLE;

-- 使用 UPDATE 语句将值从临时表更新到 combined_table_1
UPDATE combined_table_1 c
LEFT JOIN temp_Growth_Rate_Index_GICS t1 ON YEAR(c.sp_Date) = t1.year AND c.GICS_id = t1.GICS_id
LEFT JOIN temp_Profit_Rate_Index_GICS t2 ON YEAR(c.sp_Date) = t2.year AND c.GICS_id = t2.GICS_id
SET 
    c.Growth_Rate_Index = t1.category,
    c.Growth_Rate_Index_Value = t1.value,
    c.Profit_Rate_Index = t2.category,
    c.Profit_Rate_Index_Value = t2.value;

SELECT *
FROM combined_table_1
WHERE YEAR(sp_Date)>2021
ORDER BY sp_Date DESC
LIMIT 100;

DROP TABLE temp_Growth_Rate_Index;
DROP TABLE temp_Growth_Rate_Index_GICS;
DROP TABLE temp_Profit_Rate_Index;
DROP TABLE temp_Profit_Rate_Index_GICS;







