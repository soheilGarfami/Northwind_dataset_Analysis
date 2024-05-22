SELECT OrderID FROM Orders
GROUP BY OrderID, ShipPostalCode
HAVING COUNT(*) != 1;

WITH Temp AS 
( 
    SELECT *, ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY OrderID) AS RowNum
    FROM Orders 
)
DELETE FROM Temp WHERE RowNum > 1;

--

SELECT COUNT(*) FROM [Order Details] 
WHERE Discount IS NULL;

UPDATE [Order Details] SET Discount = 0 
WHERE Discount IS NULL;

--

SELECT CustomerID, ContactName FROM Customers
WHERE ContactName LIKE '%/%';

UPDATE Customers 
SET ContactName = REPLACE(ContactName, '/', ' ') 
WHERE ContactName LIKE '%/%';

--

SELECT ProductID, UnitsInStock, ProductName 
FROM Products
WHERE UnitsInStock < 0;

UPDATE Products SET UnitsInStock = ABS(UnitsInStock)  
WHERE UnitsInStock < 0;

--

SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%ID%' AND IS_NULLABLE = 'YES';

ALTER TABLE Orders ALTER COLUMN EmployeeID INT NOT NULL;
ALTER TABLE Products ALTER COLUMN SupplierID INT NOT NULL; 
ALTER TABLE Products ALTER COLUMN CategoryID INT NOT NULL; 


--

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%date%' AND DATA_TYPE != 'date';

ALTER TABLE Orders ALTER COLUMN ShippedDate DATE;

--

SELECT Country FROM Customers 
WHERE LEFT(Country, 1) COLLATE Latin1_General_BIN NOT BETWEEN 'A' AND 'Z';

UPDATE Customers 
SET Country = 
    CASE 
        WHEN LEFT(Country, 1) COLLATE Latin1_General_BIN NOT BETWEEN 'A' AND 'Z' 
        THEN UPPER(LEFT(Country, 1)) + SUBSTRING(Country, 2, LEN(Country) - 1) 
        ELSE Country
    END;


---

SELECT Description FROM Categories;

SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME = 'Description';

ALTER TABLE Categories ALTER COLUMN Description varchar(MAX);

SELECT CategoryID, Value
FROM Categories
CROSS APPLY STRING_SPLIT(REPLACE(Categories.Description, ', and ', ' , '), ',');


--


SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE ='BASE TABLE'


--

select * from Employees
SELECT * FROM Customers
select * from Suppliers
SELECT * FROM  Orders  B JOIN [Order Details]  C ON B.OrderID = C.OrderID
select * from Products a join Categories b on a.CategoryID = b.CategoryID
select * from Shippers
select * from EmployeeTerritories a join Territories b on a.TerritoryID = b.TerritoryID join Region c on b.RegionID = c.RegionID


--

SELECT ShipCountry  , COUNT(DISTINCT CustomerID) AS Number_of_Cuetomers,COUNT(OrderID) Number_Of_orders
FROM Orders
GROUP BY ShipCountry
ORDER BY 2 DESC , 3 DESC


--


WITH temp AS (
SELECT A.OrderID,  SUM(B.UnitPrice * Quantity) as sum_Of_price , sum(discount* B.UnitPrice * Quantity) as discount 
FROM  Orders AS A  JOIN [Order Details] AS B ON A.OrderID = B.OrderID
GROUP BY A.OrderID)
SELECT C.CompanyName ,C.Country,  C.City ,  SUM( ROUND(sum_Of_price - discount , 2)) AS total_spent 
from temp AS A join Orders AS b ON A.OrderID =B.OrderID 
JOIN Customers AS C ON B.CustomerID = C.CustomerID
GROUP BY C.CompanyName  ,C.Country, C.City
ORDER BY 4 DESC



--


WITH joinedOrders AS (
SELECT b.* , c.ProductID , c.Quantity FROM  Orders  B JOIN [Order Details]  C ON B.OrderID = C.OrderID
),
joinedProduct AS (
SELECT a.* , b.CategoryName FROM Products a JOIN Categories b ON a.CategoryID = b.CategoryID
)
SELECT a.ProductID ,b.ProductName ,b.CategoryName, SUM(Quantity) AS total 
FROM joinedOrders a JOIN joinedProduct b ON a.productID = b.productID
GROUP BY a.ProductID , b.ProductName , b.CategoryName
ORDER BY 4 DESC

--

SELECT  CASE WHEN TitleOfCourtesy = 'Mr.' THEN 'male' ELSE 'female' END AS  gender, 
COUNT(*) AS number_of_employees FROM Employees  
WHERE ReportsTo is not null
GROUP BY CASE WHEN TitleOfCourtesy = 'Mr.' THEN 'male' ELSE 'female' END 


--

CREATE VIEW bestEmployee AS 
SELECT a.FirstName , a.LastName , a.Title , COUNT(DISTINCT b.OrderID) AS TOTAL_NUMBER_OF_SALE
FROM Employees a join Orders b ON a.EmployeeID = b.EmployeeID  JOIN [Order Details]  C ON B.OrderID = C.OrderID
GROUP BY a.FirstName , a.LastName , a.Title
HAVING  Title  = 'Sales Representative'

--
SELECT * FROM bestEmployee
ORDER BY  4 DESC


--


SELECT  c.RegionDescription, COUNT(DISTINCT a.EmployeeID)  AS Number_of_
FROM EmployeeTerritories a JOIN Territories b ON a.TerritoryID = b.TerritoryID 
JOIN Region c ON b.RegionID = c.RegionID
GROUP BY c.RegionDescription

--
SELECT City, CompanyName, ContactName, 'supplier' AS relation FROM Suppliers 
UNION 
SELECT City, CompanyName, ContactName, 'customer' AS relation FROM Customers
GROUP BY City, CompanyName, ContactName
ORDER BY 1;



--


SELECT b.CompanyName, b.ContactName, b.ContactTitle, b.City, Phone, a.ProductName, a.UnitPrice 
FROM Products AS a 
JOIN Suppliers AS b ON a.SupplierID = b.SupplierID
WHERE a.UnitsInStock < 10 AND a.UnitsOnOrder = 0;

--

SELECT a.ShipName , a.ShipAddress , a.ShipCity , a.ShipRegion , a.ShipPostalCode , a.ShipCountry ,
c.CompanyName AS customer_name , c.Address AS customer_adress , d.FirstName + ' ' + d.LastName AS SalesPerson , 
a.OrderID , a.OrderDate , a.RequiredDate , a.ShippedDate , g.CompanyName AS shipper_name , 
b.ProductID , k.ProductName , k.UnitPrice , b.Quantity , b.Discount , a.Freight,
(k.UnitPrice * b.Quantity) * (1 - b.Discount) AS final_price 
FROM  Orders  a JOIN [Order Details]  b ON a.OrderID = b.OrderID
JOIN Customers c ON a.CustomerID = c.CustomerID 
JOIN Employees d ON a.EmployeeID = d.EmployeeID
JOIN Shippers g ON a.ShipVia  =  g.ShipperID 
JOIN Products k ON b.ProductID = k.ProductID




--



SELECT YEAR(OrderDate) as YEAR , COUNT(a.OrderID)  AS num_of_orders 
FROM  Orders  a JOIN [Order Details]  b ON a.OrderID = b.OrderID
GROUP BY YEAR(OrderDate) 
ORDER BY 1

--

SELECT d.CategoryName , c.ProductName ,ROUND(SUM((b.UnitPrice * b.Quantity) * (1 - b.Discount)),2)  AS total
FROM  Orders  a JOIN [Order Details]  b ON a.OrderID = b.OrderID
JOIN Products c ON b.ProductID = c.ProductID
JOIN Categories  d ON c.CategoryID = d.CategoryID
WHERE YEAR(a.OrderDate) = 1997
GROUP BY    c.ProductName ,  d.CategoryName 
ORDER BY d.CategoryName



