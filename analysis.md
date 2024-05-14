# Analyzing Northwind Database

***Introduction:***  
Welcome to my portfolio project, where I dive deep into the **Northwind database**, a comprehensive dataset representing a fictional trading company's operations. Through *SQL* queries and *powerBI* visual analysis, I aim to extract valuable insights that can inform strategic decision-making and drive business growth.

***Objective:***  
The primary objective of this project is to showcase my SQL skills and analytical capabilities by dissecting various aspects of the Northwind database. By conducting a thorough analysis, I aim to uncover actionable insights that can add value to the company's operations and facilitate informed decision-making processes.

***What is Northwind dataset ?***
The Northwind dataset is a comprehensive fictional database representing the operations of a trading company, encompassing information on customers, products, orders, suppliers, and employees. It serves as a valuable resource for database management, analysis, and learning purposes, providing a simulated yet realistic environment for exploring business scenarios and conducting data-driven investigations.

 *now lets have an over view of our tables*
```SQL
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE ='BASE TABLE'
```
| Database | Schema | Table_name      | Type      |
|----------|--------|-----------------|-----------|
| Northwind| dbo    | Region          | BASE TABLE|
| Northwind| dbo    | Territories     | BASE TABLE|
| Northwind| dbo    | EmployeeTerritories | BASE TABLE|
| Northwind| dbo    | Employees       | BASE TABLE|
| Northwind| dbo    | Categories      | BASE TABLE|
| Northwind| dbo    | Customers       | BASE TABLE|
| Northwind| dbo    | Shippers        | BASE TABLE|
| Northwind| dbo    | Suppliers       | BASE TABLE|
| Northwind| dbo    | Orders          | BASE TABLE|
| Northwind| dbo    | Products        | BASE TABLE|
| Northwind| dbo    | Order Details   | BASE TABLE|

<br>

-----

<br>
<br>  

***Let's see our costumers are from wich countries***

```sql
SELECT ShipCountry  , COUNT(DISTINCT CustomerID) AS Number_of_Cuetomers, COUNT(OrderID) Number_Of_orders
FROM Orders
GROUP BY ShipCountry
ORDER BY 2 DESC , 3 DESC
``` 
the top six row would be :
| Country    | Number_of_Costumers | Number_of_Orders |
|------------|----------|---------|
| USA        | 13       | 122     |
| Germany    | 11       | 122     |
| France     | 10       | 77      |
| Brazil     | 9        | 83      |
| UK         | 7        | 56      |
| Mexico     | 5        | 28      |

<br>

---
<br>
<br>  

***let's see our most profitable costumers***  
also we will take look at their countries and cities 

```sql 
WITH temp AS 
(
SELECT A.OrderID,  SUM(B.UnitPrice * Quantity) as sum_Of_price , sum(discount* B.UnitPrice * Quantity) as discount 
FROM  Orders AS A  JOIN [Order Details] AS B ON A.OrderID = B.OrderID
GROUP BY A.OrderID
)
SELECT C.CompanyName ,C.Country,  C.City ,  SUM( ROUND(sum_Of_price - discount , 2)) AS total_spent 
from temp AS A join Orders AS b ON A.OrderID =B.OrderID 
JOIN Customers AS C ON B.CustomerID = C.CustomerID
GROUP BY C.CompanyName  ,C.Country, C.City
ORDER BY 4 DESC
```
the top ten row would be :
| Customer Name               | Country | City           | Total    |
|-----------------------------|---------|----------------|------------|
| QUICK-Stop                  | Germany | Cunewalde      | 110277.31  |
| Ernst Handel                | Austria | Graz           | 104874.97  |
| Save-a-lot Markets          | USA     | Boise          | 104361.95  |
| Rattlesnake Canyon Grocery  | USA     | Albuquerque    | 51097.8    |
| Hungry Owl All-Night Grocers| Ireland | Cork           | 49979.91   |
| Hanari Carnes               | Brazil  | Rio de Janeiro | 32841.37   |
| Königlich Essen             | Germany | Brandenburg    | 30908.38   |
| Folk och fä HB              | Sweden  | Bräcke         | 29567.57   |
| Mère Paillarde              | Canada  | Montréal       | 28872.19   |
|White Clover Markets         |	USA     |	Seattle	 |27363.61

<br>

---
<br>
<br>  

***now lest take look at our most popular products***  
the row 'total' here indicate the total number of sold 

```sql 
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

```
| Product_Id | Product_Name          | CategoryName    | Total |
|------------|-----------------------|-----------------|-------|
| 60         | Camembert Pierrot     | Dairy Products  | 1577  |
| 59         | Raclette Courdavault  | Dairy Products  | 1496  |
| 31         | Gorgonzola Telino     | Dairy Products  | 1397  |
| 56         | Gnocchi di nonna Alice| Grains/Cereals  | 1263  |
| 16         | Pavlova               | Confections     | 1158  |
| 75         | Rhönbräu Klosterbier  | Beverages       | 1155  |
| 24         | Guaraná Fantástica    | Beverages       | 1125  |
| 40         | Boston Crab Meat      | Seafood         | 1103  |
| 62         | Tarte au sucre        | Confections     | 1083  |
| 2          | Chang                 | Beverages       | 1057  |

<br>

---
<br>
<br>  

***Now let's take a look at our employees***
```sql
SELECT  CASE WHEN TitleOfCourtesy = 'Mr.' THEN 'male' ELSE 'female' END AS  gender, 
COUNT(*) AS number_of_employees FROM Employees  
WHERE ReportsTo is not null
GROUP BY CASE WHEN TitleOfCourtesy = 'Mr.' THEN 'male' ELSE 'female' END 
```
|gender | number_of_employees |
| ---   |:-------------------:|
|female	|      5              |
|male	|         3           |
<br>

*Let's see our sales persons with their number of sale made*
```sql
CREATE VIEW bestEmployee AS 
SELECT a.FirstName , a.LastName , a.Title , COUNT(DISTINCT b.OrderID) AS TOTAL_NUMBER_OF_SALE
FROM Employees a join Orders b ON a.EmployeeID = b.EmployeeID  JOIN [Order Details]  C ON B.OrderID = C.OrderID
GROUP BY a.FirstName , a.LastName , a.Title
HAVING  Title  = 'Sales Representative'
```
```SQL
SELECT * FROM bestEmployee  
ORDER BY  4 DESC 
```
| FirstName | LastName  | Title                  | Total_number_of_Sale |
|-----------|-----------|------------------------|----------------------|
| Margaret  | Peacock   | Sales Representative   | 156                  |
| Janet     | Leverling | Sales Representative   | 127                  |
| Nancy     | Davolio   | Sales Representative   | 123                  |
| Robert    | King      | Sales Representative   | 72                   |
| Michael   | Suyama    | Sales Representative   | 67                   |
| Anne      | Dodsworth | Sales Representative   | 43                   |
<br>

number of employees in each rigion
```sql
SELECT  c.RegionDescription, COUNT(DISTINCT a.EmployeeID)  AS Number_of_Employees
FROM EmployeeTerritories a JOIN Territories b ON a.TerritoryID = b.TerritoryID 
JOIN Region c ON b.RegionID = c.RegionID
GROUP BY c.RegionDescription
```
| Region   | Number_of_Employees|
|----------|-------------------|
| Eastern  | 4                 |
| Northern | 2                 |
| Southern | 1                 |
| Western  | 2                 |

<br>

---
<br>
<br>  

***let's take a look at the companies that we work with and our relations***
```sql
SELECT City, CompanyName, ContactName, 'supplier' AS relation FROM Suppliers 
UNION 
SELECT City, CompanyName, ContactName, 'customer' AS relation FROM Customers
GROUP BY City, CompanyName, ContactName
ORDER BY 1;
```
the top ten row would be :
| City          | CompanyName                    | ContactName      | Relation |
|---------------|--------------------------------|------------------|----------|
| Århus         | Vaffeljernet                   | Palle Ibsen      | customer |
| Aachen        | Drachenblut Delikatessen       | Sven Ottlieb     | customer |
| Albuquerque   | Rattlesnake Canyon Grocery     | Paula Wilson     | customer |
| Anchorage     | Old World Delicatessen         | Rene Phillips    | customer |
| Ann Arbor     | Grandma Kelly's Homestead      | Regina Murphy    | supplier |
| Annecy        | Gai pâturage                   | Eliane Noz       | supplier |
| Barcelona     | Galería del gastrónomo         | Eduardo Saavedra | customer |
| Barquisimeto  | LILA-Supermercado              | Carlos González  | customer |
| Bend          | Bigfoot Breweries              | Cheryl Saylor    | supplier |
| Bergamo       | Magazzini Alimentari Riuniti   | Giovanni Rovelli | customer |
<br>

---
<br>
<br>  

***Now let's see for which product we have Low quantity in our Stock***   
also we will add the suplier contact info for ordering
```sql
SELECT b.CompanyName, b.ContactName, b.ContactTitle, b.City, Phone, a.ProductName, a.UnitPrice 
FROM Products AS a 
JOIN Suppliers AS b ON a.SupplierID = b.SupplierID
WHERE a.UnitsInStock < 10 AND a.UnitsOnOrder = 0;
```
| CompanyName                        | ContactName    | ContactTitle             | City         | Phone          | ProductName                | UnitPrice |
|------------------------------------|----------------|--------------------------|--------------|----------------|----------------------------|-----------|
| New Orleans Cajun Delights         | Shelley Burke  | Order Administrator      | New Orleans  | (100) 555-4822 | Chef Anton's Gumbo Mix     | 21.35     |
| Grandma Kelly's Homestead          | Regina Murphy  | Sales Representative     | Ann Arbor    | (313) 555-5735 | Northwoods Cranberry Sauce | 40.00     |
| Pavlova, Ltd.                      | Ian Devling    | Marketing Manager        | Melbourne    | (03) 444-2343  | Alice Mutton               | 39.00     |
| Plutzer Lebensmittelgroßmärkte AG | Martin Bein    | International Marketing  | Frankfurt    | (069) 992755   | Thüringer Rostbratwurst   | 123.79    |
| G'day, Mate                        | Wendy Mackenzie| Sales Representative     | Sydney       | (02) 555-5914  | Perth Pasties              | 32.80     |

<br>

---
<br>
<br>  

***Now we want to create invoice for every order that we have***
```sql
--CREATE VIEW Invoices AS 
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
```
the top five row would be :
| ShipName                 | ShipAddress         | ShipCity          | ShipRegion | ShipPostalCode | ShipCountry | CustomerName             | CustomerAddress      | SalesPerson      | OrderID | OrderDate             | RequiredDate          | ShippedDate            | ShipperName      | ProductID | ProductName                   | UnitPrice | Quantity | Discount | Freight | FinalPrice |
|--------------------------|---------------------|-------------------|------------|----------------|-------------|--------------------------|----------------------|------------------|---------|-----------------------|-----------------------|------------------------|------------------|-----------|-------------------------------|-----------|----------|----------|---------|------------|
| Vins et alcools Chevalier | 59 rue de l'Abbaye | Reims             | NULL       | 51100          | France      | Vins et alcools Chevalier | 59 rue de l'Abbaye | Steven Buchanan  | 10248   | 1996-07-04 00:00:00 | 1996-08-01 00:00:00 | 1996-07-16 00:00:00    | Federal Shipping | 11        | Queso Cabrales                | 21.00     | 12       | 0        | 32.38   | 252        |
| Vins et alcools Chevalier | 59 rue de l'Abbaye | Reims             | NULL       | 51100          | France      | Vins et alcools Chevalier | 59 rue de l'Abbaye | Steven Buchanan  | 10248   | 1996-07-04 00:00:00 | 1996-08-01 00:00:00 | 1996-07-16 00:00:00    | Federal Shipping | 42        | Singaporean Hokkien Fried Mee | 14.00     | 10       | 0        | 32.38   | 140        |
| Vins et alcools Chevalier | 59 rue de l'Abbaye | Reims             | NULL       | 51100          | France      | Vins et alcools Chevalier | 59 rue de l'Abbaye | Steven Buchanan  | 10248   | 1996-07-04 00:00:00 | 1996-08-01 00:00:00 | 1996-07-16 00:00:00    | Federal Shipping | 72        | Mozzarella di Giovanni         | 34.80     | 5        | 0        | 32.38   | 174        |
| Toms Spezialitäten       | Luisenstr. 48       | Münster           | NULL       | 44087          | Germany     | Toms Spezialitäten       | Luisenstr. 48       | Michael Suyama   | 10249   | 1996-07-05 00:00:00 | 1996-08-16 00:00:00 | 1996-07-10 00:00:00    | Speedy Express   | 14        | Tofu                          | 23.25     | 9        | 0        | 11.61   | 209.25     |
| Toms Spezialitäten       | Luisenstr. 48       | Münster           | NULL       | 44087          | Germany     | Toms Spezialitäten       | Luisenstr. 48       | Michael Suyama   | 10249   | 1996-07-05 00:00:00 | 1996-08-16 00:00:00 | 1996-07-10 00:00:00    | Speedy Express   | 51        | Manjimup Dried Apples         | 53.00     | 40       | 0        | 11.61   | 2120       |

<br>

---
<br>
<br>  

***now we take look at our orders by in every year***
```sql
SELECT YEAR(OrderDate) as YEAR , COUNT(a.OrderID)  AS num_of_order 
FROM  Orders  a JOIN [Order Details]  b ON a.OrderID = b.OrderID
GROUP BY YEAR(OrderDate) 
ORDER BY 1
```
| Year | Number_of_Orders |
|------|------------------|
| 1996 | 405              |
| 1997 | 1059             |
| 1998 | 691              |

Now we look more at the year **1997** 
```SQL
SELECT d.CategoryName , c.ProductName ,ROUND(SUM((b.UnitPrice * b.Quantity) * (1 - b.Discount)),2)  AS total
FROM  Orders  a JOIN [Order Details]  b ON a.OrderID = b.OrderID
JOIN Products c ON b.ProductID = c.ProductID
JOIN Categories  d ON c.CategoryID = d.CategoryID
WHERE YEAR(a.OrderDate) = 1997
GROUP BY    c.ProductName ,  d.CategoryName 
ORDER BY d.CategoryName
```
 | CategoryName | ProductName               | TotalRevenue |
|--------------|---------------------------|--------------|
| Beverages    | Chai                      | 4887.00      |
| Beverages    | Chang                     | 7038.55      |
| Beverages    | Chartreuse verte          | 4475.70      |
| Beverages    | Côte de Blaye             | 49198.09     |
| Beverages    | Guaraná Fantástica        | 1630.13      |
| Beverages    | Ipoh Coffee               | 11069.90     |
| Beverages    | Lakkalikööri              | 7379.10      |
| Beverages    | Laughing Lumberjack Lager | 910.00       |
| Beverages    | Outback Lager             | 5468.40      |
| Beverages    | Rhönbräu Klosterbier      | 4485.54      |
