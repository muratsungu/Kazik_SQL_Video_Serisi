/*
Her ürün kategorisi için:
Yıllık satış
YoY growth %
 */

;with YearlySales as (
Select c.ProductCategoryID, YEAR(s.ModifiedDate) SalesYear,SUM(s.LineTotal) Sales
from [Sales].[SalesOrderDetail] s
join [Production].[Product] p on p.ProductID = s.ProductID
join [Production].[ProductSubcategory] c on c.ProductSubcategoryID = p.ProductSubcategoryID
group by cube(c.ProductCategoryID), YEAR(s.ModifiedDate)
)
,YearlySaleswithLag as (
select ProductCategoryID,SalesYear,Sales,LAG(Sales) over (partition by ProductCategoryID order by ProductCategoryID,SalesYear) LastYearSales
from YearlySales)

select ProductCategoryID,SalesYear,Sales,(Sales-LastYearSales)/LastYearSales
from YearlySaleswithLag