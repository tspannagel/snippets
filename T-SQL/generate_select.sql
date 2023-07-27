/*
generate a select statement for a view or table while ignoring certain columns 
*/

WITH tablesAndViews AS (
    SELECT object_id, schema_id, name, 'view' as 'type' FROM sys.views
    UNION ALL
    SELECT object_id, schema_id, name, 'table' FROM sys.tables
)
SELECT CONCAT('SELECT ', STRING_AGG(c.name, CONCAT(', ', CHAR(13)+CHAR(9))), ' FROM [', s.name, '].[', t.name , ']') AS 'Query'
FROM tablesAndViews t 
INNER JOIN sys.schemas s on t.schema_id = s.schema_id
INNER JOIN sys.all_columns c on t.object_id = c.object_id
WHERE t.name = 'vArtActiveIngredients'
AND c.name NOT IN ('')
GROUP BY t.name, s.name


