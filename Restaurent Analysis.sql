

--SUM AND COUNT AGGREGATE FUNCTIONS
--RANKING FUNCTIONS 
--GROUP BY CLAUSE AND ORDER BY CLAUSE 
--CASE STATEMENTS
--COMMON TABLE EXPRESSIONS
 
CREATE SCHEMA dannys_diner;

/*
 *  Create Sales Table
 * 
 */

CREATE TABLE dannys_diner.sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dannys_diner.sales (
 customer_id, 
  order_date,
  product_id
 )
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
/*
 *  Create Menu Table
 * 
 */
 

CREATE TABLE dannys_diner.menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER,
  PRIMARY KEY (product_id)
);

INSERT INTO dannys_diner.menu (
 product_id, 
 product_name, 
 price
)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

/*
 *  Create Members Table
 * 
 */


CREATE TABLE dannys_diner.members (
  customer_id VARCHAR(1) UNIQUE NOT NULL,
  join_date DATE
);

INSERT INTO dannys_diner.members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


  SELECT * FROM[dannys_diner].[members]
    SELECT * FROM[dannys_diner].[menu]
	SELECT * FROM [dannys_diner].[sales]


--SUM AND COUNT AGGREGATE FUNCTIONS
--RANKING FUNCTIONS 
--GROUP BY CLAUSE AND ORDER BY CLAUSE 
--CASE STATEMENTS
--COMMON TABLE EXPRESSIONS

----1. WHAT IS THE TOTAL AMOUNT EACH CUSTOMER  SPENT AT THE RESTAURENT


SELECT [dannys_diner].[sales].customer_id,SUM ([dannys_diner].[menu].price) AS price
FROM [dannys_diner].[sales] 
INNER JOIN [dannys_diner].[menu] ON [dannys_diner].[sales].product_id = [dannys_diner].[menu].product_id
GROUP BY [dannys_diner].[sales].customer_id

select s.customer_id,sum(m.price)as price 
from dannys_diner.sales s 
inner join dannys_diner.menu m on s.product_id = m.product_id
group by s.customer_id


----2. HOW MANY DAYS HAS EACH CUSTOMER VISTED THE RESTAURANT

select customer_id,count( distinct order_date) as visitedays
from dannys_diner.sales
group by customer_id



-----3. WHAT WAS THE FIRST ITEM PURCHASED BY EACH CUSTOMER

WITH CTE
AS
(
select S.customer_id,M.product_name,S.order_date, 
RANK() OVER(PARTITION BY S.customer_id order by S.order_date) as RK
from dannys_diner.sales S
inner join dannys_diner.menu M on S.product_id = M.product_id
)

select distinct * from CTE
where RK=1


-----4.WHAT IS THE MOST PURCHASED ITEM ON THE MENU AND HOW MANY TIMES IT PURCHASED BY ALL CUSTOMERS ?


SELECT TOP 1 M.product_name,COUNT(M.product_id) AS CT
 FROM dannys_diner.sales S
INNER JOIN  dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY M.product_name
ORDER BY CT DESC

 
 ----5.WHICH ITEM WAS THE MOST POPULAR FOR EACH CUSTOMER?

 WITH CTE
 AS 
 (

 SELECT 
 S.customer_id,
 M.product_name,
 COUNT(M.product_id) AS NO_PURCHASED,
 RANK() OVER(PARTITION BY S.customer_id ORDER BY COUNT (M.product_id) DESC ) AS RK
 FROM dannys_diner.sales S
INNER JOIN  dannys_diner.menu M ON S.product_id = M.product_id
GROUP BY S.customer_id,M.product_name
)

SELECT customer_id,product_name, NO_PURCHASED

FROM CTE
WHERE RK=1 


----6.WHICH ITEM WAS PURCHASED FIRST BY THE CUSTOMER AFTER THEY BECAME A MEMBER?

WITH CTE
AS


(
SELECT S.customer_id,
MEM.join_date,
M.product_name,
RANK() OVER(PARTITION BY MEM.customer_id order by S.order_date) AS rk

from dannys_diner.sales S
INNER JOIN dannys_diner.menu M ON S.product_id = M.product_id
INNER JOIN dannys_diner.members MEM ON MEM.customer_id = S.customer_id
where S.order_date >= MEM.join_date
)

SELECT * FROM CTE
WHERE rk = 1

---7.WHICH ITEM WAS PURCHASED JUST BEFORE THE CUSTOMER BEACAME A MEMEBER?


WITH CTE
AS
(

SELECT S.customer_id,
M.product_name,
MEM.join_date,
RANK() OVER(PARTITION BY MEM.customer_id order by S.order_date) as rk

FROM dannys_diner.sales S
INNER JOIN dannys_diner.menu M ON S.product_id = M.product_id
INNER JOIN dannys_diner.members MEM ON MEM.customer_id = S.customer_id

where S.order_date < MEM.join_date

)

SELECT * FROM CTE
WHERE rk=1






