import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
import requests
import mysql.connector

Comps = ["MSFT", "AAPL", "NVDA", "AVGO", "BRK-B", "JPM",
         "LLY", "UNH", "AMZN", "GE", "GOOG", "WMT", "XOM", "LIN",]

nltk.download('vader_lexicon')
sia = SentimentIntensityAnalyzer()

# newsapi return example:
# {'status': 'ok',
#  'totalResults': 123,
#  'articles': [{'source': {'id': None, 'name': 'Biztoc.com'},
#    'author': 'investors.com',
#    'title': "xxxxxx",
#    'description': 'xxxxx',
#    'url': 'https://xxxxx',
#    'urlToImage': 'https://xxxxxxx',
#    'publishedAt': '2024-03-01T23:28:14Z',
#    'content': "xxxxx"},
#  ]
# }

# use example -> get_news("MSFT", "2024-03-01", "2022-04-01")


def get_news_by_newsapi(query: str, fromTime: str, toTime: str):
    api_key = '490c4bd988b94431886ee1bd945a5e11'
    url = 'https://newsapi.org/v2/everything'
    params = {
        'q': query,
        'from': fromTime,
        'to': toTime,
        'sortBy': 'publishedAt',
        'apiKey': api_key
    }
    response = requests.get(url, params=params)
    data = response.json()
    resp = []
    for i in data['articles']:
        resp.append({
            'content': i['content'],
            'url': i['url'],
            'publishedAt': i['publishedAt'],
            'title': i['title']
        })
    return resp

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
        return f"{date_pieces[0]}{date_pieces[1]}{date_pieces[2]}T0000"
    apiKey = '5AUQ5HPEMD1DV66G'
    url = f'https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers={query}&limit={limit}&apikey={apiKey}&time_from={convert_date_format(fromTime)}&time_to={convert_date_format(toTime)}'
    r = requests.get(url)
    data = r.json()
    return data

# get_score return example: {'neg': 0.0, 'neu': 1.0, 'pos': 0.0, 'compound': 0.0}
# compound 是最终打分，大于0为正面，小于0为负面


def get_score(text: str):
    score = sia.polarity_scores(text)
    return score

# get_month_news_for_company: 对股票(公司)名，获取从202X到202X年每个月的新闻打分细节


def get_month_news_for_company(compName: str, startYear: int, endYear: int):
    news = []
    for y in range(startYear, endYear + 1):  # 遍历从202X到202X年
        for m in range(1, 12):  # 遍历12个月
    
            comp_news = get_news_by_newsapi(
                compName, f'{y}-{m}-1', f'{y}-{m+1}-1')
            for artical in comp_news['articles']:
                score = get_score(artical['content'])  # 这里是打分逻辑
                news.append({
                    'name': compName,
                    'url': artical['url'],
                    'publishedAt': artical['publishedAt'],
                    'compound': score['compound'],
                })
    return news

# 获取所有公司的记录


def get_month_news_for_companies(comps: list, startYear: int, endYear: int):
    return [get_month_news_for_company(comp, startYear, endYear) for comp in comps]


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
