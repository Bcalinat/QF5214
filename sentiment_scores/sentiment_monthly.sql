SELECT *
FROM sentiment
LIMIT 10;


-- 月度创建

-- 创建名为 a 的临时视图
CREATE VIEW a AS
SELECT symbol,
    LEFT(date, 6) as month,
    sentiment_scores
FROM sentiment;

-- 创建 sentiment_monthly 表并填充数据
CREATE TABLE IF NOT EXISTS sentiment_monthly AS
SELECT symbol,
    month,
    AVG(sentiment_scores) AS avg_sentiment_scores
FROM a
GROUP BY symbol,
    month;
-- 删除临时视图
DROP VIEW IF EXISTS a;




-- 日度

-- 创建名为 a 的临时视图
CREATE VIEW a AS
SELECT symbol,
    LEFT(date, 8) as day,
    sentiment_scores
FROM sentiment;
-- 创建 sentiment_daily 表并填充数据
CREATE TABLE IF NOT EXISTS sentiment_daily AS
SELECT symbol,
    day,
    AVG(sentiment_scores) AS avg_sentiment_scores
FROM a
GROUP BY symbol,
    day;
-- 删除临时视图
DROP VIEW IF EXISTS a;
