/*
Ürünleri fiyat bantlarına göre sıralayarak en yüksek fiyatlı ilk 3 fiyat bandını listeleyiniz. 
Aynı fiyattaki ürünler aynı fiyat bandında yer almalıdır. ListPrice değeri 0 olan ürünler dikkate alınmayacaktır.
 */

;with ranks as (
select ProductID,Name,ListPrice
		,dense_rank() over (order by ListPrice desc) denserank
from Production.Product
where ListPrice > 0
)

select * from ranks
where denserank <= 3