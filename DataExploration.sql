--Total sales made per year
SELECT YEAR(order_date) AS Years, FORMAT(SUM(list_price-(list_price*discount)), '#,###,###') AS Total_Amount
FROM (
  SELECT o.order_date, ot.list_price,ot.discount
  FROM sales.orders AS o
  INNER JOIN sales.order_items AS ot
  ON o.order_id = ot.order_id
) AS joined_data
GROUP BY YEAR(order_date)
ORDER BY Total_Amount;

--Total sales made in the month of 2017
SELECT CASE MONTH(order_date)
WHEN 1 THEN 'January'
WHEN 2 THEN 'February'
WHEN 3 THEN 'March'
WHEN 4 THEN 'April'
WHEN 5 THEN 'May'
WHEN 6 THEN 'June'
WHEN 7 THEN 'July'
WHEN 8 THEN 'August'
WHEN 9 THEN 'September'
WHEN 10 THEN 'October'
WHEN 11 THEN 'November'
WHEN 12 THEN 'December' END 
AS Months_of_2017, FORMAT(SUM(list_price-(list_price*discount)), '#,###,###') AS Total_Amount
FROM (
  SELECT o.order_date, ot.list_price,ot.discount
  FROM sales.orders AS o
  INNER JOIN sales.order_items AS ot
  ON o.order_id = ot.order_id
) AS joined_data
WHERE YEAR(order_date)='2017'
GROUP BY MONTH(order_date)
ORDER BY Total_Amount DESC;

--Total sales made in the months of 2018
SELECT CASE MONTH(order_date)
WHEN 1 THEN 'January'
WHEN 2 THEN 'February'
WHEN 3 THEN 'March'
WHEN 4 THEN 'April'
WHEN 5 THEN 'May'
WHEN 6 THEN 'June'
WHEN 7 THEN 'July'
WHEN 8 THEN 'August'
WHEN 9 THEN 'September'
WHEN 10 THEN 'October'
WHEN 11 THEN 'November'
WHEN 12 THEN 'December' END 
AS Months_of_2018, FORMAT(SUM(list_price-(list_price*discount)), '#,###,###') AS Total_Amount
FROM (
  SELECT o.order_date, ot.list_price,ot.discount
  FROM sales.orders AS o
  INNER JOIN sales.order_items AS ot
  ON o.order_id = ot.order_id
) AS joined_data
WHERE YEAR(order_date)='2018'
GROUP BY MONTH(order_date)
ORDER BY Months_of_2018 DESC;

--Total sales made in the month of 2016
SELECT CASE MONTH(order_date)
WHEN 1 THEN 'January'
WHEN 2 THEN 'February'
WHEN 3 THEN 'March'
WHEN 4 THEN 'April'
WHEN 5 THEN 'May'
WHEN 6 THEN 'June'
WHEN 7 THEN 'July'
WHEN 8 THEN 'August'
WHEN 9 THEN 'September'
WHEN 10 THEN 'October'
WHEN 11 THEN 'November'
WHEN 12 THEN 'December' END 
AS Months_of_2016, FORMAT(SUM(list_price-(list_price*discount)), '#,###,###') AS Total_Amount
FROM (
  SELECT o.order_date, ot.list_price,ot.discount
  FROM sales.orders AS o
  INNER JOIN sales.order_items AS ot
  ON o.order_id = ot.order_id
) AS joined_data
WHERE YEAR(order_date)='2016'
GROUP BY MONTH(order_date)
ORDER BY Total_Amount DESC;

--Top-selling bike brands by quantity or revenue
SELECT brand_name,SUM(quantity) as total_quantity
FROM
(SELECT br.brand_name,oi.quantity
 FROM production.products AS pr
 JOIN
 production.brands AS br
 ON  pr.brand_id=br.brand_id
 JOIN
 sales.order_items AS oi
 ON
 pr.product_id=oi.product_id) AS joinedtables
 GROUP BY brand_name
 ORDER BY total_quantity DESC

--Brands bringing in the highest revenue
SELECT brand_name,FORMAT(SUM(list_price-(list_price*discount)), '#,###,###') as total_revenue
FROM
(SELECT br.brand_name,oi.list_price,oi.discount
 FROM production.products AS pr
 JOIN
 production.brands AS br
 ON  pr.brand_id=br.brand_id
 JOIN
 sales.order_items AS oi
 ON
 pr.product_id=oi.product_id) AS joinedtables
 GROUP BY brand_name
 ORDER BY total_revenue DESC

--Brands bringing in the highest revenue with total income
WITH NewRevenueCTE AS (
  SELECT 
    br.brand_name,
    SUM(oi.list_price - (oi.list_price * oi.discount)) AS total_revenue
  FROM production.products AS pr

  JOIN production.brands AS br ON pr.brand_id = br.brand_id

  JOIN sales.order_items AS oi ON pr.product_id = oi.product_id

  GROUP BY br.brand_name
)
SELECT
  brand_name,
  FORMAT(total_revenue, '#,###,###') AS total_revenue,
  FORMAT(SUM(total_revenue) OVER (ORDER BY total_revenue DESC), '#,###,###') AS running_total
FROM
  NewRevenueCTE;

--Sales performance by different sales staff (number of sales, total revenue generated) 
SELECT 
    first_name,
    last_name,FORMAT(SUM(ori.list_price - (ori.list_price * ori.discount)),'#,###,###') AS generated_revenue, 
    RANK() OVER(ORDER BY SUM(ori.list_price - (ori.list_price * ori.discount))DESC) as ranking
FROM sales.orders as ord
JOIN sales.staffs as sta ON ord.staff_id=sta.staff_id
JOIN sales.order_items as ori ON ord.order_id=ori.order_id
GROUP BY first_name,last_name
ORDER BY generated_revenue DESC

--Average order value and total number of orders.
SELECT COUNT(*) As Number_of_orders
FROM sales.orders;

WITH OrdersCTE AS (
    SELECT 
        oi.order_id, 
        oi.list_price, 
        oi.discount
    FROM 
        sales.order_items AS oi
    JOIN 
        sales.orders AS ord
    ON 
        oi.order_id = ord.order_id
)
SELECT 
    order_id, 
    AVG(list_price - (list_price * discount)) AS Average_Value
FROM 
    OrdersCTE
GROUP BY 
    order_id;

--Total no. of bikes bought, Most and least frequently purchased bike brands
SELECT 
  bra.brand_name,
  SUM(ori.quantity) as amount_bought, 
  SUM(SUM(ori.quantity)) OVER(ORDER BY SUM(ori.quantity) ) as total_amount
FROM production.brands as bra 
JOIN production.products as pro ON bra.brand_id=pro.brand_id
JOIN sales.order_items as ori ON pro.product_id=ori.product_id
GROUP BY bra.brand_name

--Average shipping time
SELECT 
    AVG(DATEDIFF(day, order_date, shipped_date)) AS Average_Shipping_Time
FROM 
    sales.orders;

--Average shipping time per store
SELECT 
Store_name,
AVG(DATEDIFF(hour, order_date, shipped_date)) AS Average_Shipping_Hours, RANK() OVER(ORDER BY(AVG(DATEDIFF(hour, order_date, shipped_date)))) AS Ranking
FROM sales.orders as ord
JOIN sales.stores as sto
ON ord.store_id=sto.store_id
GROUP BY store_name

--Stock amount per store
SELECT sst.store_name, SUM(pst.quantity) AS quantity_of_bikes_in_stock
FROM production.stocks as pst
JOIN sales.stores as sst
ON pst.store_id=sst.store_id
GROUP BY store_name

--Top Customers
SELECT 
  scu.first_name,
  scu.last_name,
  SUM(sori.quantity) as quantity_bought,
  COUNT(sor.order_id) AS number_of_orders
FROM sales.customers as scu
JOIN sales.orders as sor ON scu.customer_id=sor.customer_id
JOIN sales.order_items as sori ON sor.order_id=sori.order_id 
GROUP BY first_name,last_name
ORDER BY quantity_bought DESC

--Duplicate Findings
SELECT 
  customer_id,
  COUNT(*) as amount
FROM sales.customers
GROUP BY customer_id
HAVING count(*) > 1

--Count of customers who have ordered the same product
WITH Temp AS (
    SELECT ori.product_id,
    ord.customer_id,
    cus.first_name,
    cus.last_name  
FROM sales.orders AS ord

JOIN sales.order_items as ori ON ord.order_id=ori.order_id

JOIN sales.customers as cus ON cus.customer_id=ord.customer_id)

SELECT 
    t1.product_id,
    COUNT(DISTINCT t1.customer_id) as customer_count 

FROM Temp as t1
JOIN Temp as t2 ON t1.product_id =t2.product_id AND t1.customer_id <> t2.customer_id
GROUP BY t1.product_id
ORDER BY customer_count DESC

--Revenue from each product
SELECT 
    ori.product_id,
    FORMAT(SUM(ori.list_price),'#,###,###' ) AS product_revenue

FROM sales.orders AS ord

JOIN sales.order_items as ori ON ord.order_id=ori.order_id

JOIN sales.customers as cus ON cus.customer_id=ord.customer_id

GROUP BY product_id 

ORDER BY product_revenue DESC

--Customers who ordered specific products
SELECT 
    ori.product_id,
    ord.customer_id,
    cus.first_name,
    cus.last_name,
    ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY first_name) as eachrow
    
FROM sales.orders AS ord

JOIN sales.order_items as ori ON ord.order_id=ori.order_id

JOIN sales.customers as cus ON cus.customer_id=ord.customer_id

WHERE ori.product_id =3

---Number of sales made per product
SELECT 
  product_id, 
  COUNT(ori.product_id) as count_of_sales_per_product

FROM sales.orders AS ord

JOIN sales.order_items as ori ON ord.order_id=ori.order_id

JOIN sales.customers as cus ON cus.customer_id=ord.customer_id

GROUP BY product_id

ORDER BY count_of_sales_per_product DESC

----Checking if there is any product where a particular customer bought twice
SELECT 
    cus.customer_id,
    cus.first_name,
    cus.last_name,
    ori.product_id,
    COUNT(ori.product_id) as product_count
    
FROM sales.orders AS ord

JOIN sales.order_items as ori ON ord.order_id=ori.order_id

JOIN sales.customers as cus ON cus.customer_id=ord.customer_id

GROUP BY 
    cus.customer_id,
    ori.product_id,
    cus.first_name,
    cus.last_name
HAVING COUNT(ori.product_id) >1

-- Find customers who bought the same product more than once
WITH CustomerProductOrders AS (
    SELECT
        cus.customer_id,
        cus.first_name,
        cus.last_name,
        ori.product_id,
        COUNT(ori.product_id) AS product_count
    FROM
        sales.orders AS ord
        JOIN sales.order_items AS ori ON ord.order_id = ori.order_id
        JOIN sales.customers AS cus ON cus.customer_id = ord.customer_id
    GROUP BY
        cus.customer_id,
        cus.first_name,
        cus.last_name,
        ori.product_id
)
SELECT
    customer_id,
    first_name,
    last_name,
    product_id,
    product_count
FROM
    CustomerProductOrders
WHERE
    product_count > 1
ORDER BY
    customer_id, product_id;

--Identify staff members who manage other staff members
SELECT
     employee.staff_id,
     employee.first_name employee_name,
     manager.first_name manager_name,
     COUNT(manager.first_name)OVER(PARTITION BY manager.first_name ORDER BY manager.first_name ASC) no_of_employees_per_manager
FROM sales.staffs as employee
JOIN sales.staffs as manager ON employee.manager_id=manager.staff_id
WHERE employee.staff_id <> manager.staff_id


