

### Checking for Duplicates
So let's see if we have any **Duplicates** ?
```sql 
SELECT OrderID FROM Orders
GROUP BY OrderID, ShipPostalCode
HAVING COUNT(*) != 1;
```

| OrderID |
|---------|
| 11068   |
| 11026   |
| 10850   |
| 10688   |
| 10528   |
| 10252   |

As you can see, for each of these IDs, we have **more than one** row.  
Let's add a row number to each row for every OrderID and delete the rows where the row number is more than 1.

```sql
WITH Temp AS 
( 
    SELECT *, ROW_NUMBER() OVER(PARTITION BY OrderID ORDER BY OrderID) AS RowNum
    FROM Orders 
)
DELETE FROM Temp WHERE RowNum > 1;
```

<br>
<hr>
<br>
<br>

### Updating Null Values in Discounts

In the table *Order Details*, in the column *Discount*, we have some null values.  
Let's change them to 0***<u>0</u>***.

```sql
SELECT COUNT(*) FROM [Order Details] 
WHERE Discount IS NULL;
```

| count(*) |
|----------|
| 11       |

As you can see, we have ***11*** rows that are null.

```sql
UPDATE [Order Details] SET Discount = 0 
WHERE Discount IS NULL;
```  

<br>
<hr>
<br>
<br>

### Correcting Mistyped Contact Names

In the table *Customers*, column *ContactName*, we have some mistyped slashes ("/") in the names.

```sql
SELECT CustomerID, ContactName FROM Customers
WHERE ContactName LIKE '%/%';
```

| CustomerID | ContactName         |
|------------|----------------------|
| BERGS      | Chri/stina Berglund  |
| FURIB      | Lino Rod/riguez      |
| LINOD      | Felipe Izqu/ierdo    |
| ROMEY      | Ale/jandra Camino    |
| WARTH      | Pirkko Koski/talo    |

Let's delete the slashes ("/") from the names.

```sql
UPDATE Customers 
SET ContactName = REPLACE(ContactName, '/', ' ') 
WHERE ContactName LIKE '%/%';
```

<br>
<hr>
<br>
<br>

### Correcting Negative Units In Stock

In the table *Products*, we have some negative *UnitsInStock* values.

```sql
SELECT ProductID, UnitsInStock, ProductName 
FROM Products
WHERE UnitsInStock < 0;
```

| ProductID | UnitsInStock | ProductName               |
|-----------|--------------|---------------------------|
| 8         | -6           | Northwoods Cranberry Sauce|
| 21        | -3           | Sir Rodney's Scones       |
| 58        | -62          | Escargots de Bourgogne    |

It is probably a typo mistake.  
Let's just make them positive.

```sql
UPDATE Products SET UnitsInStock = ABS(UnitsInStock)  
WHERE UnitsInStock < 0;
```

<br>
<hr>
<br>
<br>

### Ensuring Non-Null ID Columns

In relational tables, the ID columns are usually **primary** or **foreign** keys.  
So, normally we shouldn't be allowed to add a null value.

 ```sql 
SELECT TABLE_NAME, COLUMN_NAME, IS_NULLABLE, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%ID%' AND IS_NULLABLE = 'YES';
```

| TABLE_NAME | COLUMN_NAME | IS_NULLABLE | DATA_TYPE |
|------------|-------------|-------------|-----------|
| Orders     | EmployeeID  | YES         | int       |
| Products   | SupplierID  | YES         | int       |
| Products   | CategoryID  | YES         | int       |

As you can see, these three columns are nullable.   
Let's change them to "NOT NULL".

```sql 
ALTER TABLE Orders ALTER COLUMN EmployeeID INT NOT NULL;
ALTER TABLE Products ALTER COLUMN SupplierID INT NOT NULL; 
ALTER TABLE Products ALTER COLUMN CategoryID INT NOT NULL; 
```

<br>
<hr>
<br>
<br>

### Correcting Date Columns

In SQL, we have a data type called ***date*** that we use for date values.   
Let's see if we have any columns that are not in the right format.

```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%date%' AND DATA_TYPE != 'date';
```

| TABLE_NAME | COLUMN_NAME | DATA_TYPE |
|------------|-------------|-----------|
| Orders     | ShippedDate | varchar   |

As you can see, the ShippedDate is in varchar type. Let's change it to date.

```sql
ALTER TABLE Orders ALTER COLUMN ShippedDate DATE;
```

<br>
<hr>
<br>
<br>

### Correcting Country Names

In the *Customers* table, we have some country names that start with a lowercase letter.

```sql 
SELECT Country FROM Customers 
WHERE LEFT(Country, 1) COLLATE Latin1_General_BIN NOT BETWEEN 'A' AND 'Z';
```

| Country |
|---------|
| spain   |
| sweden  |
| france  |

Let's fix this.

```sql
UPDATE Customers 
SET Country = 
    CASE 
        WHEN LEFT(Country, 1) COLLATE Latin1_General_BIN NOT BETWEEN 'A' AND 'Z' 
        THEN UPPER(LEFT(Country, 1)) + SUBSTRING(Country, 2, LEN(Country) - 1) 
        ELSE Country
    END;
```

<br>
<hr>
<br>
<br>

### Breaking Down Descriptions

Let's take a look at the *Description* column in the *Categories* table.

```sql
SELECT Description FROM Categories;
```

| Description                                                |
|------------------------------------------------------------|
| Soft drinks, coffees, teas, beers, and ales                |
| Sweet and savory sauces, relishes, spreads, and seasonings |
| Desserts, candies, and sweet breads                        |
| Cheeses                                                    |
| Breads, crackers, pasta, and cereal                        |
| Prepared meats                                             |
| Dried fruit and bean curd                                  |
| Seaweed and fish                                           |

Let's break them down into separate rows. We are going to use *STRING_SPLIT*.   
But to use this, the column can't be of the data type **ntext**.

```sql
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME = 'Description';
```

| DATA_TYPE |
|-----------|
| ntext     |

```sql
ALTER TABLE Categories ALTER COLUMN Description varchar(MAX);
```

Now we can use *STRING_SPLIT*.

```sql
SELECT CategoryID, Value
FROM Categories
CROSS APPLY STRING_SPLIT(REPLACE(Categories.Description, ', and ', ' , '), ',');
```
| categoryID | value                         |
|------------|-------------------------------|
| 1          | Soft drinks                   |
| 1          | coffees                       |
| 1          | teas                          |
| 1          | beers                         |
| 1          | ales                          |
| 2          | Sweet and savory sauces       |
| 2          | relishes                      |
| 2          | spreads                       |
| 2          | seasonings                    |
| 3          | Desserts                      |
| 3          | candies                       |
| 3          | sweet breads                  |
| 4          | Cheeses                       |
| 5          | Breads                        |
| 5          | crackers                      |
| 5          | pasta                         |
| 5          | cereal                        |
| 6          | Prepared meats                |
| 7          | Dried fruit and bean curd     |
| 8          | Seaweed and fish              |


<br>



---
***Great job! Now we are good to go! ;)***

---


