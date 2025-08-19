drop table if exists zepto;
create table zepto(
sku_id SERIAL Primary key,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
dicountedsellingPrice Numeric(8,2),
weightInGms INTEGER,
outofstock BOOLEAN,
quantity INTEGER
);

--data exploration

--count of rows

SELECT COUNT (*) From zepto;


--sample data
select * from zepto
Limit 10;


--null values
select * from zepto
where name is null
or
 mrp is null
or
 discountPercent is null
or 
 availableQuantity is null
or
 dicountedsellingPrice is null
or
 weightInGms is null
or
 outOfStock is null
or
 quantity is null;

 --diffrent Product categories

 select distinct category
 from zepto
 order by category;

 ---product in stock vs out of stock
 select outofstock,count(sku_id)
 from zepto
 group by outofstock;

 --Product name present multiple times
 select name, count(sku_id) as "Number of SKUs"
 from zepto
 group by name
 having count(sku_id)>1
 order by count(sku_id) Desc;

 --data cleaning

 --products with price = 0
 select * from zepto
 where mrp =0;

 delete from zepto
 where mrp = 0;

 --covert paise to rupees
update zepto
set mrp = mrp/100.0,
dicountedsellingPrice = dicountedsellingPrice/100.0;

select mrp,dicountedsellingPrice
from zepto;

--Buisness
--Q1. Find the top 10 best-value products based on the discount percentage.

select Distinct name, mrp, discountPercent
from zepto
order by discountPercent desc
limit 10;

--Q2.What are the Products with High MRP but Out of Stock

select distinct name,mrp
from zepto
where outofstock = True and mrp >300
order by mrp desc;

--Q3.Calculate Estimated Revenue for each category

select category,
sum(dicountedsellingPrice*availableQuantity) AS Total_revenue
from zepto 
group by category
order by Total_revenue desc;

--Q4. Find all products where MRP is greater than 500 and discount is less than 10%.
select distinct name,mrp,discountPercent
from  zepto 
where mrp>500 and discountPercent <10
order by mrp desc, discountpercent desc;

--Q5. Identify the top 5 categories offering the highest average discount percentage.

select category,
ROUND(AVG(discountPercent),2) AS avg_discount
from zepto
group by category
order by avg_discount DESC
LIMIT 5;

--Q6. Find the price per gram for products above 100g and sort by best value.
Select distinct name, weightInGms, dicountedsellingPrice,
ROUND(dicountedsellingPrice/weightInGms,2) as price_per_gram
from zepto
where weightInGms >=100
Order by price_per_gram;
--Q7.Group the products into categories like Low, Medium, Bulk.
Select Distinct name, weightInGms,
Case When weightInGms < 1000 Then 'Low'
	 When weightInGms < 5000 Then 'Medium'
	 else 'Bulk'
	 end as weight_category
From zepto;
--08.What is the Total Inventory Weight Per Category
 Select category,
 sum(weightInGms*availableQuantity) as Total_weight
 from Zepto
 Group by category
 order by Total_weight desc;