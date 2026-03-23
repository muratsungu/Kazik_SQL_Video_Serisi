/*
Aşağıdaki kırılımlar için satış toplamlarını, müşteri sayılarını ve ilk sipariş tarihlerini gösteren bir sorgu yazınız.
TerritoryName, OnlineOrderFlag
Sonuçların Territory'ler için dip toplamını getir.
 */

select IIF(grouping(t.name) = 1, 'Total', t.name) TerritoryName,OnlineOrderFlag
	,SUM(TotalDue) TotalSales
	,COUNT(DISTINCT CustomerID) CustomerCount
	,MIN(OrderDate) FirstOrder
from [Sales].[SalesOrderHeader] s
join [Sales].[SalesTerritory] t on s.TerritoryID = t.TerritoryID
group by cube(t.Name),OnlineOrderFlag
order by t.Name,OnlineOrderFlag