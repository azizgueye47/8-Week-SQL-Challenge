--1)Quel est le montant total dépensé par chaque client au restaurant ?

SELECT sales.customer_id , sum (menu.price) as montant_total_depense
	
FROM dannys_diner.menu as menu

join dannys_diner.sales as sales

ON sales.product_id=menu.product_id

group by 1

order by 2 desc

--2)Combien de jours chaque client a-t-il visité le restaurant ?

SELECT customer_id,count(order_date) as nombre_de_visite

FROM dannys_diner.sales

group by 1

order by 2 desc

--3)Quel a été le premier élément du menu acheté par chaque client ?(recherche)


SELECT s.customer_id, s.order_date, m.product_name
FROM dannys_diner.sales s
JOIN dannys_diner.menu m ON s.product_id = m.product_id
WHERE (s.customer_id, s.order_date) IN (
    SELECT customer_id, MIN(order_date)
    FROM dannys_diner.sales
    GROUP BY customer_id
);

--4)Quel est l’article le plus acheté sur le menu et combien de fois a-t-il été acheté par tous les clients ?

SELECT product_name , count(product_name) as nombre_fois_commande

FROM dannys_diner.sales As sales

join dannys_diner.menu as menu 

on menu.product_id=sales.product_id

group by product_name

order by 2 desc

--5)Quel article a été le plus populaire pour chaque client ?

WITH TABLEAU AS (
	SELECT customer_id ,product_name   , SUM(order_count) AS orders_count ,
	
       DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY SUM(order_count) desc  ) as rang
	
	FROM (select  sales.customer_id  ,menu.product_name
	, count(sales.customer_id) as order_count

     from dannys_diner.sales As sales

    JOIN dannys_diner.menu as menu 

    on menu.product_id =sales.product_id

    group by sales.customer_id ,menu.product_name) AS T_1

group by customer_id , product_name
)

select customer_id ,product_name , orders_count 
	
from TABLEAU

where rang=1

--6)Quel article a été acheté en premier par le client après être devenu membre ?

with TABLEAU AS (select sales.customer_id ,sales.order_date,menu.product_name,members.join_date ,
	
	RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date   ) as rang

from dannys_diner.sales as sales

inner join dannys_diner.menu as menu 

on sales.product_id=menu.product_id

inner join dannys_diner.members as members

on members.customer_id=sales.customer_id

where sales.order_date > members.join_date

order by sales.customer_id)

SELECT customer_id , product_name

FROM TABLEAU

where rang =1

--7)Quel article a été acheté juste avant que le client ne devienne membre ?

WITH TABLEAU AS (select sales.customer_id ,sales.order_date,menu.product_name,members.join_date ,
	
	RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date DESC  ) as rang

from dannys_diner.sales as sales

inner join dannys_diner.menu as menu 

on sales.product_id=menu.product_id

inner join dannys_diner.members as members

on members.customer_id=sales.customer_id

where sales.order_date < members.join_date )

SELECT customer_id ,product_name 

FROM TABLEAU

where rang =1

--8)Quel est le nombre total d'articles et le montant dépensé pour chaque membre avant de devenir membre ?

WITH TABLEAU AS (select sales.customer_id , menu.product_name ,sum(menu.price) as montant

from dannys_diner.sales as sales

inner join dannys_diner.menu as menu 

on sales.product_id=menu.product_id

inner join dannys_diner.members as members

on members.customer_id=sales.customer_id

where sales.order_date < members.join_date 

group by sales.customer_id , menu.product_name 

order by montant  desc )

SELECT customer_id,sum(montant) over (partition by product_name order by montant) montant_depense ,
	count(product_name) OVER (partition by customer_id order by montant)  nombre_article  
	
	 

FROM TABLEAU
limit 2

--9)Si chaque dollar dépensé équivaut à 10 points et que les sushis ont un multiplicateur de points de 2x, combien de points chaque client aurait-il ?
 
with tableau as (SELECT customer_id , product_name , price  , 10*price as price_gagner ,
	
(CASE
	WHEN product_name='sushi' THEN 2
      
    ELSE 0
END) as sushi_gagner 

FROM dannys_diner.sales as sales

inner join dannys_diner.menu as menu 

on sales.product_id= menu.product_id)

select customer_id , sum((price_gagner + price_gagner)) as nombre_de_point_gagner

from tableau 

group by 1 
order by 2 desc













