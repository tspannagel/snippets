WITH ddls AS (
    SELECT
        'DROP PROCEDURE [' + s.name + '].[' + t.name + ']' AS 'Drop DDL',
        'Stored Procedures' AS 'ObjectType',
        s.name AS 'SchemaName',
        t.name AS 'ObjectName'
    FROM sys.procedures t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id AND s.schema_id > 4
    UNION ALL
    SELECT
        'DROP VIEW [' + s.name + '].[' + t.name + ']',
        'Views',
        s.name,
        t.name
    FROM sys.views t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id AND s.schema_id > 4
    UNION ALL
    SELECT
        'DROP TABLE [' + s.name + '].[' + t.name + ']',
        'Tables',
        s.name,
        t.name
    FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id AND s.schema_id > 4
    UNION ALL
    SELECT
        'DROP SCHEMA [' + s.name + ']',
        'Schemas',
        s.name,
        null
    FROM sys.schemas s WHERE s.schema_id > 4 AND s.schema_id < 16384
)

SELECT * FROM ddls
