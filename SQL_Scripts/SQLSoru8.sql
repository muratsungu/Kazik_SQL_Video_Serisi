/*  Territorylere göre aylık satış toplamlarını gösteren bir sorgu yazınız. Eğer o ay ve bölgede satış yok ise 0 değeri döndürünüz.
    Sonrasında yılları satırlarda olacak, Territoryler sütunlarda olacak şekilde sonuç döndürünüz. (Pivot kullanarak)
    Fakat pivot'da kolon isimlerini tek tek yazmak yerine dinamik olarak oluşturunuz.
 */

DECLARE @COLS NVARCHAR(MAX) 
DECLARE @QUERY NVARCHAR(MAX) 
SELECT @COLS = STRING_AGG(QUOTENAME(Name),',') FROM Sales.SalesTerritory

SET @QUERY = '
;with dates as (
select CAST(''2011-01-01'' as Date) OrderMonth
union all
select dateadd(month,1,OrderMonth)
from dates 
where OrderMonth < ''2012-01-01'')

,crossjoin AS 
(
select D.OrderMonth,T.Name TerritoryName from Sales.SalesTerritory t
CROSS JOIN dates D
)
,SALES AS (
select DATEADD(MONTH, DATEDIFF(MONTH, 0, s.OrderDate), 0) OrderMonth,t.Name as TerritoryName,SUM(s.TotalDue) as Total
from Sales.SalesOrderHeader s
join Sales.SalesTerritory t on s.TerritoryID = t.TerritoryID
group by DATEADD(MONTH, DATEDIFF(MONTH, 0, s.OrderDate), 0),t.Name
)
,FINAL AS (
SELECT C.OrderMonth,C.TerritoryName,ISNULL(S.Total,0) Total
FROM crossjoin C
LEFT JOIN SALES S ON C.OrderMonth =S.OrderMonth AND C.TerritoryName = S.TerritoryName
)

SELECT * FROM FINAL
PIVOT (
SUM(Total)
FOR TerritoryName IN ('+ @COLS + ')
) AS PIVOTTABLE';

EXEC sp_executesql @QUERY
