/* 
created with synapse serverless pool in mind.
Can also be used as a strating point to create a persisted date dimension.

*/
CREATE VIEW vDimDate AS
WITH cteYear AS (
    SELECT 1970 as 'year'
    UNION ALL
    SELECT year + 1 FROM cteYear WHERE year < 2070 -- serverless pool has max recursion depth of 100
),
cteMonth as (
    SELECT 1 AS 'month'
    UNION ALL 
    SELECT month + 1 FROM cteMonth WHERE month < 12
),
cteDays AS (
    SELECT 1 AS 'day'
    UNION ALL 
    SELECT day +1 FROM cteDays WHERE day < 31
)

SELECT 
    CONVERT(INT,CONCAT(year,STUFF('00',3-LEN(m.month),LEN(m.month),m.month), STUFF('00',3-LEN(d.day),LEN(d.day),d.day))) AS 'dateId'
    ,CONVERT(DATETIME,CONCAT(year,STUFF('00',3-LEN(m.month),LEN(m.month),m.month), STUFF('00',3-LEN(d.day),LEN(d.day),d.day))) AS 'calendarDate'
    ,year AS 'calendarYear'
    ,month AS 'calendarMonthNumber'
    ,day AS 'calendarDayNumber'
    ,FORMAT(CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, d.day)),'MMMM') AS 'calendarMonthName'
    ,FORMAT(CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, d.day)),'dddd') AS 'calendarDayName'
    ,EOMONTH(CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, d.day))) AS 'endOfMonth'
    ,DATEPART(qq, CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, d.day))) AS 'calendarQuarter'
    ,DATEPART(ww, CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, d.day))) AS 'calendarWeek'
    ,CASE 
        WHEN y.year = YEAR(GETDATE())-1 
            THEN 1 
            ELSE 0 
        END AS 'isPreviousToCurrentYear'
    ,y.year-1 AS 'previousYear'
FROM cteYear y 
CROSS JOIN cteMonth m
CROSS JOIN cteDays d WHERE d.day <= DAY(EOMONTH(CONVERT(DATETIME,CONCAT_WS('-', y.year,m.month, '01')))) /*only join days according to the month of the according year. this considers leap years*/
