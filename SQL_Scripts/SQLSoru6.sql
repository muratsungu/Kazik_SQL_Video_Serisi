/*
Yıllık ve çeyreklik satış toplamlarını göstermek için pivot ve unpivot işlemlerini kullanarak bir sorgu yazınız.
Çeyrekler Q1, Q2, Q3 ve Q4 olarak adlandırılmalıdır.
 */


;with sales as (
select YEAR(OrderDate) Years ,DATEPART(QUARTER,OrderDate) Quarters,SUM(TotalDue) Total
from sales.SalesOrderHeader
group by YEAR(OrderDate),DATEPART(QUARTER,OrderDate)
)
select Years,[1] as Q1,[2] as Q2 ,[3] as Q3 ,[4] as Q4  
into #pivot
from sales
pivot (
sum(Total)
for Quarters in ([1],[2],[3],[4])
) as pivottable

select * from #pivot
unpivot (
Total for Quarters in ([Q1],[Q2],[Q3],[Q4])
) as unpivottable
order by 1,3

--Daha detaylı bilgi için: https://www.mssqltips.com/sqlservertip/7233/sql-pivot-sql-unpivot-examples-transform-data/