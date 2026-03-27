/* Günlük bazda kategoriye göre aşağıdaki metrikleri hesaplayan bir sorgu yazın:
     kullanıcı sayısı, 
     gelir, 
     MTD gelir, 
     7 günlük hareketli ortalama gelir, 
     bir önceki günün geliri, 
     büyüme oranı ve 
     ani artış bayrağı (gelirin bir önceki günün iki katından fazla olup olmadığı) 
     
 Veriyi 2013-06-01 ile 2013-07-31 tarihleri arasında filtreleyelim.
 */
;WITH fact AS (
    SELECT
        CAST(soh.OrderDate AS DATE) AS dt,
        pc.Name AS category,
        soh.CustomerID,
        SUM(sod.LineTotal) AS revenue
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p       ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc    ON ps.ProductCategoryID = pc.ProductCategoryID
	WHERE soh.OrderDate BETWEEN '2013-06-01' AND  '2013-07-31'
    GROUP BY CAST(soh.OrderDate AS DATE), pc.Name, soh.CustomerID
),


daily AS (
    SELECT
        dt,
        category,
        COUNT(DISTINCT CustomerID) AS users,
        SUM(revenue) AS revenue
    FROM fact
    GROUP BY dt, cube(category)
),

metrics AS (
    SELECT
        d.*,

        SUM(revenue) OVER (
            PARTITION BY category, YEAR(dt), MONTH(dt)
            ORDER BY dt
        ) AS revenue_mtd,

        SUM(revenue) OVER (
            PARTITION BY category
            ORDER BY dt
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS revenue_7d,

        LAG(revenue) OVER (
            PARTITION BY category ORDER BY dt
        ) AS prev_day

    FROM daily d
),

growth AS (
    SELECT *,
        (revenue - prev_day) * 1.0 / NULLIF(prev_day, 0) AS growth_rate,
        CASE WHEN revenue > 2 * ISNULL(prev_day, 0) THEN 1 ELSE 0 END AS spike_flag
    FROM metrics
) 
select * from growth
order by 1,2
