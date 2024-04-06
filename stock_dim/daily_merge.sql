-- stock_price ,yahoo_esg_score, search_popularity,sentiment_daily

-- 1. yahoo_esg_score
-- 1.1 创建新表，保留原始表的结构，但将 symbol 列的校对规则修改为 utf8mb4_unicode_ci
CREATE TABLE new_yahoo_esg_score LIKE yahoo_esg_score;
ALTER TABLE new_yahoo_esg_score CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 1.2 复制数据到新表中
INSERT INTO new_yahoo_esg_score
SELECT * FROM yahoo_esg_score;

SHOW FULL COLUMNS FROM yahoo_esg_score;
SHOW FULL COLUMNS FROM new_yahoo_esg_score;
SHOW FULL COLUMNS FROM search_popularity_rows;
-- SHOW FULL COLUMNS FROM search_popularity;


-- 2. search_popularity
CREATE TABLE IF NOT EXISTS search_popularity_rows AS
SELECT 'MSFT' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, MSFT as search_popularity
FROM search_popularity 
UNION ALL
SELECT 'AAPL' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, AAPL as search_popularity
FROM search_popularity
UNION ALL
SELECT 'NVDA' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, NVDA as search_popularity
FROM search_popularity
UNION ALL
SELECT 'AVGO' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, AVGO as search_popularity
FROM search_popularity
UNION ALL
SELECT 'BRK-B' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, `BRK-B` as search_popularity
FROM search_popularity
UNION ALL
SELECT 'JPM' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, JPM as search_popularity
FROM search_popularity
UNION ALL
SELECT 'LLY' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, LLY as search_popularity
FROM search_popularity
UNION ALL
SELECT 'UNH' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, UNH as search_popularity
FROM search_popularity
UNION ALL
SELECT 'AMZN' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, AMZN as search_popularity
FROM search_popularity
UNION ALL
SELECT 'GE' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, GE as search_popularity
FROM search_popularity
UNION ALL
SELECT 'GOOG' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, GOOG as search_popularity
FROM search_popularity
UNION ALL
SELECT 'WMT' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, WMT as search_popularity
FROM search_popularity
UNION ALL
SELECT 'XOM' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, XOM as search_popularity
FROM search_popularity
UNION ALL
SELECT 'LIN' as symbol,DATE_FORMAT(date,'%Y%m%d') as date, LIN as search_popularity
FROM search_popularity;

-- 3. sentiment_daily


-- 4. merge
SELECT y.symbol, DATE_FORMAT(y.date,'%Y%m%d') as date,s.date, esg_score, search_popularity
FROM new_yahoo_esg_score y
FULL OUTER JOIN search_popularity_rows s 
ON y.symbol = s.symbol 
AND DATE_FORMAT(y.date,'%Y%m%d')  = s.date 
ORDER BY y.date;

SELECT y.symbol, DATE_FORMAT(y.date,'%Y%m%d') as date,esg_score
FROM new_yahoo_esg_score y;

SELECT * FROM search_popularity_rows;

SELECT COALESCE(e.symbol, s.symbol) AS symbol,
       COALESCE(e.date, s.date) AS date,
       e.esg_score,
       s.search_popularity
FROM new_yahoo_esg_score e
LEFT JOIN search_popularity_rows s ON e.symbol = s.symbol AND e.date = s.date
UNION
SELECT COALESCE(e.symbol, s.symbol) AS symbol,
       COALESCE(e.date, s.date) AS date,
       e.esg_score,
       s.search_popularity
FROM new_yahoo_esg_score e
RIGHT JOIN search_popularity_rows s ON e.symbol = s.symbol AND e.date = s.date
WHERE e.symbol IS NULL;

-- 5.stock_price
SELECT * FROM aapl_price
LIMIT 10;