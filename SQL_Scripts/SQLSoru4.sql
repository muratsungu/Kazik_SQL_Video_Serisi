/*
3.örnekte hazırladığımız sorgu üzerinden RFM analizini yapalım
 */

;WITH snapshot AS (
    SELECT MAX(OrderDate) AS SnapshotDate
    FROM  [Sales].[SalesOrderHeader]
),

rfm_base AS (
    SELECT
       CustomerID,
       MAX(OrderDate) AS LastOrderDate,
       COUNT(1) AS Frequency,
       SUM(TotalDue) AS Monetary
    FROM [Sales].[SalesOrderHeader]
),

rfm_calc AS (
    SELECT
        b.*,
        DATEDIFF(DAY, b.LastOrderDate, s.SnapshotDate) AS Recency
    FROM rfm_base b
    CROSS JOIN snapshot s
),

rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency ASC)  AS R_Score,   -- düşük recency daha iyi
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM rfm_calc
)

SELECT
    CustomerID
    Recency,
    Frequency,
    Monetary,

    R_Score,
    F_Score,
    M_Score,

    CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

    CASE
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 4 THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2 THEN 'New Customers'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 THEN 'Hibernating'
        ELSE 'Potential Loyalists'
    END AS Segment

FROM rfm_scores
ORDER BY Monetary DESC;

