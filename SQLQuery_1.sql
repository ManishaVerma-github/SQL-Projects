use db_SQLCaseStudies
/*
1. List all the states in which we have customers who have bought cellphones from 2005 till today.
2. What state in the US is buying the most 'Samsung' cell phones?
3. Show the number of transactions for each model per zip code per state. 
4. Show the cheapest cellphone (Output should contain the price also)
5. Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.
6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500
7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.
10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.
*/
SELECT * FROM (
SELECT 'DIM_MANUFACTURER' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_MANUFACTURER UNION ALL
SELECT 'DIM_MODEL' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_MODEL UNION ALL
SELECT 'DIM_CUSTOMER' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_CUSTOMER UNION ALL
SELECT 'DIM_LOCATION' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_LOCATION UNION ALL
SELECT 'DIM_DATE' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM DIM_DATE UNION ALL
SELECT 'FACT_TRANSACTIONS' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM FACT_TRANSACTIONS
) TBL
SELECT * FROM DIM_MANUFACTURER;
SELECT * FROM DIM_MODEL;
SELECT * FROM DIM_CUSTOMER;
SELECT * FROM DIM_LOCATION;
SELECT * FROM DIM_DATE;
SELECT * FROM FACT_TRANSACTIONS;

--Q1  List all the states in which we have customers who have bought cellphones from 2005 till today.
SELECT DISTINCT STATE
FROM FACT_TRANSACTIONS AS T
JOIN DIM_LOCATION AS L
ON T.IDLocation=L.IDLocation
WHERE T.DATE BETWEEN '01-01-2005' AND GETDATE()
;

--Q2 What state in the US is buying the most 'Samsung' cell phones?
SELECT TOP 1 L.STATE
FROM FACT_TRANSACTIONS AS T
JOIN DIM_LOCATION AS L
ON T.IDLocation=L.IDLocation
JOIN DIM_MODEL AS M
ON T.IDModel=M.IDModel
JOIN DIM_MANUFACTURER AS MN
ON M.IDManufacturer=MN.IDManufacturer
WHERE L.COUNTRY='US' AND Manufacturer_Name='SAMSUNG'
GROUP BY L.STATE, COUNTRY
ORDER BY SUM(Quantity) DESC

--Q3 Show the number of transactions for each model per zip code per state. 
SELECT  MODEL_NAME, STATE, ZIPCODE, COUNT(IDCustomer) AS NO_OF_TRANSACTIONS
FROM FACT_TRANSACTIONS AS T 
JOIN DIM_LOCATION AS L
ON T.IDLocation=L.IDLocation
JOIN DIM_MODEL AS M 
ON T.IDModel=M.IDModel
GROUP BY MODEL_NAME, STATE, ZIPCODE
;

--Q4 Show the cheapest cellphone (Output should contain the price also)
SELECT IDMODEL, UNIT_PRICE
FROM DIM_MODEL
WHERE Unit_price<= (SELECT MIN(Unit_price) FROM DIM_MODEL)
;
--SECOND METHOD
SELECT TOP 1 IDMODEL, MODEL_NAME, Unit_price
FROM DIM_MODEL
ORDER BY Unit_price

/*--Q5 Find out the average price for each model in the top5 manufacturers in terms of sales quantity and 
order by average price.*/

SELECT MODEL_NAME, AVG(UNIT_PRICE) AS AVG_PRICE 
FROM DIM_MODEL AS M
INNER JOIN DIM_MANUFACTURER AS MN
ON MN.IDMANUFACTURER = M.IDMANUFACTURER
WHERE MANUFACTURER_NAME IN 
                        (
                        SELECT TOP 5 MANUFACTURER_NAME 
                        FROM FACT_TRANSACTIONS AS T
                        INNER JOIN DIM_MODEL AS M 
                        ON T.IDMODEL = M.IDMODEL
                        INNER JOIN DIM_MANUFACTURER AS MN
                        ON MN.IDMANUFACTURER = M.IDMANUFACTURER
                        GROUP BY MANUFACTURER_NAME
                        ORDER BY SUM(QUANTITY) DESC
                        )
GROUP BY MODEL_NAME
ORDER BY AVG(UNIT_PRICE) DESC
;

--Q6 List the names of the customers and the average amount spent in 2009, where the average is higher than 500
SELECT Customer_Name, avg(totalPrice) AS AVG
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_CUSTOMER AS C
ON T.IDCustomer=C.IDCustomer
WHERE T.DATE  BETWEEN '01-01-2009' AND '12-31-2009'
GROUP BY Customer_Name
HAVING AVG(TotalPrice)>500

--Q7 List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
SELECT MODEL_NAME 
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M 
ON T.IDMODEL= M.IDMODEL
GROUP BY IDMODEL 
HAVING SUM(QUANTITY) >= ALL(SELECT TOP 5 IDModel, SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2008  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC) 
AND SUM(QUANTITY) >= ALL (SELECT TOP 5 IDModel, SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2009  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC)
AND SUM(QUANTITY) >= ALL(SELECT TOP 5 IDModel, SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2010  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC)

104	6    
105	4
109	4
130	4
111	3

101	22
107	11
121	3
109	2
123	2

SELECT * FROM( SELECT TOP 5 MODEL_NAME, M.IDModel
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M 
ON T.IDMODEL= M.IDMODEL
WHERE YEAR(DATE)= 2008
GROUP BY MODEL_NAME, M.IDModel
ORDER BY SUM(Quantity) DESC) AS T1
INTERSECT
SELECT * FROM( SELECT TOP 5 MODEL_NAME 
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M 
ON T.IDMODEL= M.IDMODEL
WHERE YEAR(DATE)= 2009
GROUP BY MODEL_NAME
ORDER BY SUM(Quantity) DESC) AS T2
INTERSECT
SELECT * FROM( SELECT TOP 5 MODEL_NAME 
FROM FACT_TRANSACTIONS AS T
INNER JOIN DIM_MODEL AS M 
ON T.IDMODEL= M.IDMODEL
WHERE YEAR(DATE)= 2010
GROUP BY MODEL_NAME
ORDER BY SUM(Quantity) DESC) AS T3

(SELECT TOP 5 SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2008  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC)
INTERSECT
(SELECT TOP 5 SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2009  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC)
INTERSECT
SELECT TOP 5 SUM(QUANTITY) FROM FACT_TRANSACTIONS WHERE YEAR(DATE) = 2010  GROUP BY IDMODEL ORDER BY SUM(QUANTITY) DESC
;




--Q8 Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.
SELECT *
FROM(
        SELECT Manufacturer_Name, SUM(TotalPrice) AS SALES, YEAR(DATE) AS YEAR, 
        ROW_NUMBER() OVER (PARTITION BY YEAR(DATE)  ORDER BY SUM(TotalPrice) DESC) AS RANK
        FROM FACT_TRANSACTIONS AS T
        LEFT JOIN DIM_MODEL AS M
        ON T.IDModel=M.IDModel
        LEFT JOIN DIM_MANUFACTURER AS MN 
        ON M.IDManufacturer=MN.IDManufacturer 
        WHERE (YEAR(DATE) IN(2009, 2010)) 
        GROUP BY Manufacturer_Name, YEAR(DATE)
        
    ) AS N
WHERE RANK= 2
;

--Q9 Show the manufacturers that sold cellphones in 2010 but did not in 2009.



SELECT MN.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T 
LEFT JOIN DIM_MODEL AS M 
ON T.IDModel=M.IDModel
LEFT JOIN DIM_MANUFACTURER AS MN
ON M.IDManufacturer=MN.IDManufacturer
WHERE YEAR(DATE)=2010 
EXCEPT 
SELECT MN.Manufacturer_Name
FROM FACT_TRANSACTIONS AS T 
LEFT JOIN DIM_MODEL AS M 
ON T.IDModel=M.IDModel
LEFT JOIN DIM_MANUFACTURER AS MN
ON M.IDManufacturer=MN.IDManufacturer
WHERE YEAR(DATE)=2009





--Q10 Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

SELECT CUSTOMER_NAME,YEAR,AVG_SALES,AVG_QUANTITY,
(AVG_SALES-(LAG(AVG_SALES) OVER (PARTITION BY T.IDCUSTOMER ORDER BY YEAR )))/ (LAG(AVG_SALES) OVER (PARTITION BY T.IDCUSTOMER ORDER BY YEAR )) AS PERCENT_CHANGE
FROM
    (SELECT  IDCUSTOMER,YEAR(DATE) AS YEAR, AVG(TotalPrice) AS AVG_SALES, AVG(Quantity) AS AVG_QUANTITY
    FROM FACT_TRANSACTIONS 
    WHERE IDCUSTOMER IN (
                            SELECT IDCustomer 
                            FROM (
                                    SELECT  IDCustomer, ROW_NUMBER() OVER(ORDER BY SUM(TOTALPRICE)DESC) AS RANK
                                    FROM FACT_TRANSACTIONS 
                                    GROUP BY IDCustomer
                                 ) A 
                            WHERE RANK <=100
                        )
    GROUP BY IDCUSTOMER,YEAR(DATE)
    ) T 
JOIN DIM_CUSTOMER AS C
ON T.IDCustomer=C.IDCustomer




WHERE ROW_NUMBER() OVER(PARTITION BY YEAR(DATE) ORDER BY AVG(QUANTITY))<=100
 GROUP BY  YEAR(DATE),IDCustomer
 HAVING ROW_NUMBER() OVER(PARTITION BY YEAR(DATE) ORDER BY AVG(QUANTITY))<=100
ORDER BY AVG(TotalPrice)DESC, AVG(QUANTITY)DESC

SELECT TOP 100 T.IDCUSTOMER,
--CUSTOMER_NAME, 
AVG(CASE WHEN YEAR(DATE) = 2003 THEN TOTALPRICE END) AS AVERAGE_SPEND_2003,
AVG(CASE WHEN YEAR(DATE) = 2003 THEN QUANTITY END) AS AVERAGE_QTY_2003,
SUM(CASE WHEN YEAR(DATE) = 2003 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE_2003,

AVG(CASE WHEN YEAR(DATE) = 2004 THEN TOTALPRICE END) AS AVERAGE_SPEND_2004,
AVG(CASE WHEN YEAR(DATE) = 2004 THEN QUANTITY END) AS AVERAGE_QTY_2004,
SUM(CASE WHEN YEAR(DATE) = 2004 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE_2004,

(SUM(CASE WHEN YEAR(DATE) = 2004 THEN TOTALPRICE END)*100-SUM(CASE WHEN YEAR(DATE) = 2003 THEN TOTALPRICE END)/ SUM(TOTALPRICE)*100/ SUM(TOTALPRICE) )/SUM(CASE WHEN YEAR(DATE) = 2003 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS P_CHANGE,
AVG(CASE WHEN YEAR(DATE) = 2005 THEN TOTALPRICE END) AS AVERAGE_SPEND_2005,
AVG(CASE WHEN YEAR(DATE) = 2005 THEN QUANTITY END) AS AVERAGE_QTY_2005,
SUM(CASE WHEN YEAR(DATE) = 2005 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE_2005,

AVG(CASE WHEN YEAR(DATE) = 2006 THEN TOTALPRICE END) AS AVERAGE_SPEND_2006,
AVG(CASE WHEN YEAR(DATE) = 2006 THEN QUANTITY END) AS AVERAGE_QTY_2006,
SUM(CASE WHEN YEAR(DATE) = 2006 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE_2006,

AVG(CASE WHEN YEAR(DATE) = 2007 THEN TOTALPRICE END) AS AVERAGE_SPEND_2007,
AVG(CASE WHEN YEAR(DATE) = 2007 THEN QUANTITY END) AS AVERAGE_QTY_2007,
SUM(CASE WHEN YEAR(DATE) = 2007 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE,

AVG(CASE WHEN YEAR(DATE) = 2008 THEN TOTALPRICE END) AS AVERAGE_SPEND_2008,
AVG(CASE WHEN YEAR(DATE) = 2008 THEN QUANTITY END) AS AVERAGE_QTY_2008,
SUM(CASE WHEN YEAR(DATE) = 2008 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE,

AVG(CASE WHEN YEAR(DATE) = 2009 THEN TOTALPRICE END) AS AVERAGE_SPEND_2009,
AVG(CASE WHEN YEAR(DATE) = 2009 THEN QUANTITY END) AS AVERAGE_QTY_2009,
SUM(CASE WHEN YEAR(DATE) = 2009 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE,

AVG(CASE WHEN YEAR(DATE) = 2010 THEN TOTALPRICE END) AS AVERAGE_SPEND_2010,
AVG(CASE WHEN YEAR(DATE) = 2010 THEN QUANTITY END) AS AVERAGE_QTY_2010,
SUM(CASE WHEN YEAR(DATE) = 2010 THEN TOTALPRICE END)*100/ SUM(TOTALPRICE)  AS PERCENTAGE

FROM DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS T ON T.IDCUSTOMER= C.IDCUSTOMER
GROUP BY T.IDCustomer
ORDER BY SUM(TotalPrice)DESC, AVG(QUANTITY)DESC
;



 SELECT YEAR(DATE)
 FROM FACT_TRANSACTIONS
 GROUP BY YEAR(DATE)


SELECT *
FROM(
SELECT IDModel, SUM(TOTALPRICE) AS SALES, YEAR(DATE) AS YEAR,
ROW_NUMBER()OVER(PARTITION BY YEAR(DATE) ORDER BY SUM(TOTALPRICE))AS RANK
FROM FACT_TRANSACTIONS
GROUP BY IDModel, YEAR(DATE)
--ORDER BY YEAR(DATE)
) AS N
WHERE RANK=2

--WHICH MANUFACTURER HAS BEST CUSTOMER
SELECT *
FROM(
    SELECT IDMANUFACTURER, IDCUSTOMER,SUM(TOTALPRICE) AS SALES
      ,ROW_NUMBER() OVER( PARTITION BY IDMANUFACTURER ORDER BY SUM(TOTALPRICE)DESC) AS RANK
        FROM FACT_TRANSACTIONS AS T 
        JOIN DIM_MODEL AS M 
        ON T.IDModel=M.IDModel
        GROUP BY IDManufacturer, IDCustomer
        --ORDER BY SALES DESC
        
    )AS N
 WHERE RANK=1


