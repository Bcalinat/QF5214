import requests
import mysql.connector
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
from urllib.parse import quote

Comps = ["MSFT", "AAPL", "NVDA", "AVGO", "BRK-B", "JPM",
         "LLY", "UNH", "AMZN", "GE", "GOOG", "WMT", "XOM", "LIN",]


# example of get_news_by_alphavantage returns
# {
#     "feed": [{
#         "title": "Billionaires Are Buying Bitcoin: What Does It Mean for the Future Price of Bitcoin?",
#         "url": "https://www.fool.com/investing/2024/03/22/billionaires-are-buying-bitcoin-what-does-it-mean/",
#         "time_published": "20240322T093000",
#         "authors": [
#             "Dominic Basulto"
#         ],
#         "summary": "If billionaires are embracing crypto, that should send the price of Bitcoin soaring. But it's not guaranteed.",
#         "banner_image": "https://g.foolcdn.com/image/?url=https%3A%2F%2Fg.foolcdn.com%2Feditorial%2Fimages%2F769882%2Fgettyimages-990642348.jpg&op=resize&w=700",
#         "source": "Motley Fool",
#         "category_within_source": "n/a",
#         "source_domain": "www.fool.com",
#         "topics": [
#             {
#                 "topic": "Economy - Monetary",
#                 "relevance_score": "0.451494"
#             },
#             {
#                 "topic": "Retail & Wholesale",
#                 "relevance_score": "0.333333"
#             }
#         ],
#         "overall_sentiment_score": 0.095943,
#         "overall_sentiment_label": "Neutral",
#         "ticker_sentiment": [
#             {
#                 "ticker": "BLK",
#                 "relevance_score": "0.171485",
#                 "ticker_sentiment_score": "0.153551",
#                 "ticker_sentiment_label": "Somewhat-Bullish"
#             },
#             {
#                 "ticker": "MSTR",
#                 "relevance_score": "0.129052",
#                 "ticker_sentiment_score": "0.021225",
#                 "ticker_sentiment_label": "Neutral"
#             }
#         ]
#     }]
# }


def get_news_by_alphavantage(query: str, fromTime: str, toTime: str, limit: int = 51):
    def convert_date_format(date_str):
        date_pieces = date_str.split('-')
        month = {'1':'01', '2':'02', '3':'03', '4':'04', '5':'05', '6':'06', '7':'07', '8':'08', '9':'09', '10':'10', '11':'11', '12':'12'}
        date_pieces[1] = month.get(date_pieces[1], date_pieces[1])  
        return f"{date_pieces[0]}{date_pieces[1]}{date_pieces[2]}T0000"
    
    apiKey = '5AUQ5HPEMD1DV66G'
    url = f'https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers={query}&limit={limit}&apikey={apiKey}&time_from={convert_date_format(fromTime)}&time_to={convert_date_format(toTime)}'
    r = requests.get(url)
    data = r.json()
    return data

def convert_date_format(date_str):
    date_pieces = date_str.split('-')
    month = {'1':'01', '2':'02', '3':'03', '4':'04', '5':'05', '6':'06', '7':'07', '8':'08', '9':'09', '10':'10', '11':'11', '12':'12'}
    date_pieces[1] = month.get(date_pieces[1], date_pieces[1])  # 使用 get 方法获取字典值，若不存在则返回原值
    return f"{date_pieces[0]}{date_pieces[1]}{date_pieces[2]}T0000"

# get_month_news_for_company: 对股票(公司)名，获取从202X到202X年每个月的新闻打分细节
def get_month_news_for_company(compName: str, startYear: int, endYear: int):
	news = []
	for y in range(startYear, endYear + 1): # 遍历从202X到202X年
		m = 1
		while m <= 12: # 遍历12个月
            
			if y == 2022 and m < 3:
				m = 3
			if y ==2024 and m >3:
				break
			if m == 12:
				comp_news = get_news_by_alphavantage(compName, f'{y}-{m}-01', f'{y+1}-01-01')
				print('compName:',compName, f'{y}-{m}-01', f'{y+1}-01-01')
			else:
				comp_news = get_news_by_alphavantage(compName, f'{y}-{m}-01', f'{y}-{m+1}-01')
				print('compName:',compName, f'{y}-{m}-01', f'{y}-{m+1}-01')
			print(comp_news)
			print(convert_date_format(f'{y}-{m}-01'))
			for artical in comp_news['feed']:
				news.append({
					'name': compName,
					'url': artical['url'],
					'publishedAt': artical['time_published'],
					'compound': artical['overall_sentiment_score'],
				})
			m+=1
	return news

# 获取所有公司的记录
def get_month_news_for_companies(comps: list, startYear: int, endYear: int):
    return [get_month_news_for_company(comp, startYear, endYear) for comp in comps]


# get_score return example: {'neg': 0.0, 'neu': 1.0, 'pos': 0.0, 'compound': 0.0}
# compound 是最终打分，大于0为正面，小于0为负面



def create_mysql_table():
    mydb = mysql.connector.connect(
        host="localhost",
        user="yourusername",
        password="yourpassword",
        database="mydatabase"
    )
    mycursor = mydb.cursor()
    mycursor.execute(
        "CREATE TABLE customers (name VARCHAR(255), url VARCHAR(255))")
    mydb.commit()
    mydb.close()


def insert_mysql_table(data):
    mydb = mysql.connector.connect(
        host="localhost",
        user="yourusername",
        password="yourpassword",
        database="mydatabase"
    )

    mycursor = mydb.cursor()

    sql = "INSERT INTO your_table_name (name, url, publishedAt, compound) VALUES (%s, %s, %s, %s)"
    val = (data['name'], data['url'], data['publishedAt'], data['compound'])

    mycursor.execute(sql, val)
    mydb.commit()
    mydb.close()


def main():
    records = get_month_news_for_companies(Comps, 2022, 2023)

    # create_mysql_table()

    for record in records:
        for data in record:
            insert_mysql_table(data)
