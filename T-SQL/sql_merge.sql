WITH startRows AS (
SELECT '9b4b36ca-eab6-462b-8b6b-8ae0840ed19a' AS 'custId','John Doe' AS 'custName',' A' AS 'category'
UNION ALL
SELECT '888c2489-d2ad-4a84-a8b2-49439f547403','Max Mustermann' ,' C'
UNION ALL
SELECT '692a4597-ef3e-4f36-b31d-6171ea111d09','Jane Doe',' B '
UNION ALL
SELECT '2d0405e5-d9f6-43b1-b600-202ef8a6c299','Wonder Woman',' A'
)

SELECT startRows.*, GETDATE() AS 'scdValidFrom', CAST('2100-12-31' AS DATETIME2) AS 'scdValdiTo', 1 AS 'isCurrent' INTO #customers FROM startRows
SELECT * FROM #customers

;WITH updates AS (
SELECT '9b4b36ca-eab6-462b-8b6b-8ae0840ed19a' AS 'custId','John Doe'AS 'custName',' A'AS 'category'
UNION ALL
SELECT '3d81c64b-1d78-47c8-a4c9-3fb709879479','Donald Duck',' C'
)


/* Changed Rows */
SELECT tgt.custId
    ,COALESCE(src.custName,tgt.custName)
    ,COALESCE(src.category,tgt.category)
    ,
    
FROM #customers tgt 
INNER JOIN updates src ON src.custId = tgt.custId
WHERE tgt.isCurrent = 1


DROP TABLE #customers