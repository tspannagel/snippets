SELECT s.name as 'schema',
    t.name as 'table', 
    CONCAT('SELECT ', STRING_AGG(ac.name, ', '), ' FROM [' + s.name + '].[' + t.name + ']') AS 'query'
FROM sys.all_columns ac
    INNER JOIN sys.tables t on ac.object_id = t.object_id
    INNER join sys.schemas s on t.schema_id = s.schema_id
WHERE generated_always_type = 0 /* cant insert in generated_always columns */
    AND t.name <> '__RefactorLog'  /* refactorLog is built by the deployment process */
    AND temporal_type <> 1 /* cant insert into history tables of system_versioned tables*/
GROUP BY s.name, t.name
