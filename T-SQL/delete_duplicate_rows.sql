/*************************************************************/
/* 1. Create sample table                                    */
/*************************************************************/
CREATE TABLE Employee (
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Country VARCHAR(100)
)
GO
/*************************************************************/
/* 2. Create duplicate data and insert it                    */
/*************************************************************/


;WITH employeeInput AS (
    SELECT 'John' AS 'FirstName', 'Doe' AS 'LastName', 'Germany' AS 'Country'    
    UNION ALL
    SELECT 'Jane', 'Jonson', 'Norway'
    UNION ALL 
    SELECT 'John', 'Doe', 'Germany'
    UNION ALL
    SELECT 'Jane', 'Jonson', 'Norway'
    UNION ALL
    SELECT 'Micky', 'Mouse', 'N/A'
    UNION ALL
    SELECT 'Jane', 'Jonson', 'Norway'
)
INSERT INTO Employee 
SELECT * FROM employeeInput
GO 5

SELECT * FROM Employee


/*************************************************************/
/* 3. Identify duplicates using a cte                        */
/* 3. Delete form table using the cte results                */
/*************************************************************/


-- source: https://www.sqlshack.com/different-ways-to-sql-delete-duplicate-rows-from-a-sql-table/
;WITH duplicates 
AS (
    SELECT
        [FirstName],
        [LastName],
        [Country],
        ROW_NUMBER() OVER(
            PARTITION BY [FirstName],
            [LastName],
            [Country]
            ORDER BY NEWID()
        ) AS DuplicateCount
    FROM
        [dbo].[Employee]
)

DELETE FROM
duplicates
WHERE
    DuplicateCount > 1;


SELECT * FROM Employee


DROP TABLE Employee;