/*Her müşterinin 
ilk sipariş tarihi, 
son sipariş tarihi, 
ortalama sipariş hacmi, 
toplam sipariş hacmi ve 
sipariş sayısını 

hesaplayarak müşterileri ortalama sipariş hacmine göre 3 segmente ayırınız. Segmentleri High, Medium ve Low olarak adlandırınız.
 */

;with Customers as (
select CustomerID,MIN(OrderDate)FirstOrder,MAX(OrderDate)LastOrder,COUNT(1) OrderCnt, SUM(TotalDue) TotalOrderVolume, AVG(TotalDue) AvgOrderVolume
from [Sales].[SalesOrderHeader]
group by CustomerID
),
Segment as (
select CustomerID,NTILE(3) over (Order by AvgOrderVolume desc) Segment, FirstOrder,LastOrder,AvgOrderVolume,OrderCnt,TotalOrderVolume
from Customers
)

select CustomerID
	  ,case Segment when 1 then 'High' when 2 then 'Medium' when 3 then 'Low' end As Segment
	  ,FirstOrder,LastOrder,AvgOrderVolume,OrderCnt,TotalOrderVolume	
from Segment
