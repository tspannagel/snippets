WITH allCols
AS (
    SELECT TOP(100000000)
        t.object_id,
        s.name AS 'schema_name',
        t.name AS 'table_name',
        'ISNULL(' + CASE
            WHEN ty.name IN ('varchar', 'nvarchar', 'datetime', 'datetime2', 'datetimeoffset')
                THEN 'CASE WHEN ' + c.name + ' IS NULL THEN NULL ELSE '''''''' END +'
            ELSE ''
        END
        + CASE
            WHEN ty.name IN ('int', 'bigint', 'float', 'decimal', 'datetime', 'datetime2', 'datetimeoffset', 'bit')
                THEN ' CAST('
            ELSE ''
        END + ISNULL(c.name, 'NULL')
        + CASE
            WHEN ty.name IN ('int', 'bigint', 'float', 'decimal', 'datetime', 'datetime2', 'datetimeoffset', 'bit')
                THEN ' AS VARCHAR(25))'
            ELSE ''
        END
        + CASE
            WHEN ty.name IN ('varchar', 'nvarchar', 'datetime', 'datetime2', 'datetimeoffset')
                THEN '+ CASE WHEN ' + c.name + ' IS NULL THEN NULL ELSE '''''''' END'
            ELSE ''
        END
        + ',''NULL'')' AS 'column_value',
        c.name AS column_name,
        ty.name AS 'datatype'
    FROM sys.tables t INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.all_columns c ON t.object_id = c.object_id
    INNER JOIN sys.types ty ON c.system_type_id = ty.system_type_id
    WHERE ty.name != 'sysname'
    -- AND s.name = @schema AND t.name = @table --and t.object_id = 1298103665    
    ORDER BY object_id, column_id
),

inserts AS (
    SELECT
        object_id,
        schema_name,
        table_name,
        CONCAT('SELECT ''INSERT INTO [', schema_name, '].[', table_name, '](', STRING_AGG(CAST('[' + column_name + ']' AS VARCHAR(MAX)), ','), ') VALUES'' UNION ALL ') AS 'part1'
    FROM allCols
    GROUP BY object_id, schema_name, table_name
)

SELECT
    a.object_id,
    a.schema_name,
    a.table_name,
    part1
    + 'SELECT ''('' + '
    + STRING_AGG(column_value, '+'',''+')
    + ' + '')'' FROM [' + a.schema_name + '].[' + a.table_name + ']' AS selectValues
FROM allCols a
INNER JOIN inserts i ON a.object_id = i.object_id
GROUP BY a.object_id, a.schema_name, a.table_name, i.part1
ORDER BY table_name
