USE Adworks;

--------------------------------------------------------------------------------------------------------------------------------------
/* Joining the sales tables to create 1 overall sales table*/

SELECT *
INTO Overall_sales
FROM Aw_Sales_2015
UNION ALL
SELECT*
FROM Aw_Sales_2016
UNION ALL
SELECT*
FROM Aw_Sales_2017;
--------------------------------------------------------------------------------------------------------------------------------------

/*CUSTOMER OCCUPATION DEMOGRAPHY*/


--Calculating the customer distribution accross each occupation

SELECT occupation, COUNT(occupation) AS [Count]
FROM Aw_Customers
GROUP BY Occupation
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the Average Age of each occupation

SELECT occupation, AVG (DATEDIFF(YEAR,BirthDate, GETDATE())) AS [Average Age]
FROM Aw_Customers
GROUP BY Occupation
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the Marital Status of each occupation

SELECT occupation, MaritalStatus, COUNT (MaritalStatus) AS [Count]
FROM Aw_Customers
GROUP BY Occupation,MaritalStatus
ORDER BY 1, 3 DESC;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the Household Size of each occupation 

SELECT occupation,
		CASE WHEN TotalChildren > 2 THEN 'LargeHousehold'
		ELSE 'SmallHousehold'
		END AS [Size],
		COUNT(*) AS [Count]
FROM Aw_Customers
GROUP BY Occupation,
		CASE WHEN TotalChildren > 2 THEN 'LargeHousehold'
		ELSE 'SmallHousehold'
		END
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Calculating the Educational level of each occupation

SELECT Occupation, EducationLevel, COUNT(EducationLevel) AS [Count]
FROM Aw_Customers
GROUP BY Occupation, EducationLevel
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the Average Annual Salary of each occupation 

SELECT occupation, ROUND(AVG(AnnualIncome),2) AS [Average Annual Income]
FROM Aw_Customers
GROUP BY Occupation
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the Gender distribution per Customer Occupation

SELECT Occupation, Gender, COUNT(Gender) AS [Gender count]
FROM Aw_Customers
GROUP BY Occupation, Gender
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the distribution of Occupation accross each Country

SELECT tr.Country,ct.occupation, COUNT(ct.occupation) AS [Occupation Count]
FROM Aw_Territories tr
JOIN Overall_sales os
ON os.TerritoryKey = tr.SalesTerritoryKey
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
GROUP BY tr.Country,ct.occupation;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Calculating the percentage of occupation that are home owners

SELECT occupation, COUNT(HomeOwner) AS [Count], 
		COUNT(HomeOwner)*100/
		(SELECT COUNT(HomeOwner)
		FROM Aw_Customers 
		WHERE HomeOwner = 'Y') AS [Percentage]
FROM Aw_Customers
WHERE HomeOwner = 'Y'
GROUP BY Occupation
ORDER BY 3 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Calculating the percentage of occupation that are not home owners

SELECT occupation, COUNT(HomeOwner) AS [Count], 
		COUNT(HomeOwner)*100/
		(SELECT COUNT(HomeOwner)
		FROM Aw_Customers 
		WHERE HomeOwner = 'N') AS [Percentage]
FROM Aw_Customers
WHERE HomeOwner = 'N'
GROUP BY Occupation
ORDER BY 3 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*CUSTOMER OCCUPATION PURCHASE BEHAVIOR*/


-- Calculating the Overall Revenue for all Customer Occupation

SELECT ct.Occupation, ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY ct.Occupation
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the yearly revenue performance per Customer Occupation

SELECT YEAR(os.OrderDate) AS [Year],ct.Occupation,ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY ct.Occupation,YEAR(os.OrderDate)
ORDER BY 1,2;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the quarterly revenue performance per Customer Occupation

SELECT CASE WHEN DATEPART(QUARTER,os.OrderDate) = 1 THEN 'Q1'
			WHEN DATEPART(QUARTER,os.OrderDate) = 2 THEN 'Q2'
			WHEN DATEPART(QUARTER,os.OrderDate) = 3 THEN 'Q3'
			WHEN DATEPART(QUARTER,os.OrderDate) = 4 THEN 'Q4'
			END AS [Quarter],
			ct.Occupation,
			ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY CASE WHEN DATEPART(QUARTER,os.OrderDate) = 1 THEN 'Q1'
			WHEN DATEPART(QUARTER,os.OrderDate) = 2 THEN 'Q2'
			WHEN DATEPART(QUARTER,os.OrderDate) = 3 THEN 'Q3'
			WHEN DATEPART(QUARTER,os.OrderDate) = 4 THEN 'Q4'
			END, 
			ct.Occupation
ORDER BY 1,2;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the monthly revenue performance per Customer Occupation

SELECT DATEPART(MONTH,os.OrderDate) AS [Month_ID],DATENAME(MONTH,os.OrderDate) AS [Month],ct.Occupation,ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY DATEPART(MONTH,os.OrderDate), ct.Occupation,DATENAME(MONTH,os.OrderDate)
ORDER BY 1; 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the revenue performance per Customer Occupation for each day of the week

SELECT CASE WHEN DATEPART(WEEKDAY,os.OrderDate) = 1 THEN 8
		ELSE DATEPART(WEEKDAY,os.OrderDate)
		END AS [Day_ID],
		DATENAME(WEEKDAY,os.OrderDate) AS [Day],
		ct.Occupation,
		ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY CASE WHEN DATEPART(WEEKDAY,os.OrderDate) = 1 THEN 8
		ELSE DATEPART(WEEKDAY,os.OrderDate)
		END,
		DATENAME(WEEKDAY,os.OrderDate),
		ct.Occupation
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Calculating the revenue performance per Customer Occupation during weekdays and weekends

SELECT 
		CASE WHEN DATEPART(WEEKDAY,os.OrderDate) IN (7,8) THEN 'Weekend'
		ELSE 'Weekday'
		END AS [Day_type],
		ct.Occupation,
		ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY ct.Occupation, CASE WHEN DATEPART(WEEKDAY,os.OrderDate) IN (7,8) THEN 'Weekend'
		ELSE 'Weekday'
		END
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Calculating the number of Orders and Quantity Ordered per Customer Occupation

SELECT ct.Occupation, COUNT(DISTINCT os.OrderNumber) AS [Orders], SUM(OrderQuantity) AS [Quantity]
FROM Aw_Customers ct
JOIN Overall_sales os
ON ct.CustomerKey = os.CustomerKey
GROUP BY ct.Occupation;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Calculating the average revenue generated per customer occupation

SELECT ct.Occupation, ROUND(SUM(pt.ProductPrice * os.OrderQuantity)/ COUNT(DISTINCT os.OrderNumber),2) AS [Average Order Value]
FROM Aw_Customers ct 
JOIN Overall_sales os
ON ct.CustomerKey = os.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
GROUP BY ct.Occupation
ORDER BY 2 DESC;

--------------------------------------------------------------------------------------------------------------------------------------
-- Calculating the revenue performance for each product Category per Customer occupation

SELECT  pc.CategoryName AS [Category Name],ct.Occupation, ROUND(SUM(pt.ProductPrice * os.OrderQuantity),2) AS [Revenue]
FROM Overall_sales os
JOIN Aw_Customers ct
ON os.CustomerKey = ct.CustomerKey
JOIN Aw_Products pt
ON os.ProductKey = pt.ProductKey
JOIN Aw_Product_Subcategory ps
ON pt.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN Aw_Product_Category pc
ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY ct.Occupation,pc.CategoryName
ORDER BY 1;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Calculating the Top 3 Products ordered per Customer Occupation

WITH RankedProducts AS (
    SELECT
        ct.Occupation AS [Customer Occupation],
        pt.ProductName AS [Product],
        COUNT(DISTINCT os.OrderNumber) AS [Order Count],
        ROW_NUMBER() OVER(PARTITION BY ct.Occupation ORDER BY COUNT(DISTINCT os.OrderNumber) DESC) AS RowNum
    FROM Aw_Customers ct
    JOIN Overall_sales os ON ct.CustomerKey = os.CustomerKey
    JOIN Aw_Products pt ON pt.ProductKey = os.ProductKey
    GROUP BY ct.Occupation, pt.ProductName
)
SELECT [Customer Occupation], [Product], [Order Count]
FROM RankedProducts
WHERE RowNum <= 3
ORDER BY [Customer Occupation], [Order Count] DESC;

