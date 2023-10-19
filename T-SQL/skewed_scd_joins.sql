with invoice as (
    select 4711 as invoice_id, 1337 as material_id, CAST('2023-08-16' AS DATETIME2) AS 'date_inserted'
    UNION 
    select 4712, 1234, CAST('2023-08-01' AS DATETIME2)
        UNION 
    select 4713, 1234, CAST('2023-08-04' AS DATETIME2)

),
materials as(
        select 1337 as material_id, 'A' as 'material_name', CAST('2023-08-18' AS DATETIME2) AS 'valid_from' , CAST('2023-08-19' AS DATETIME2) AS 'valid_to'
    UNION 
        select 1337 as material_id, 'A' as 'material_name', CAST('2023-08-19' AS DATETIME2) AS 'valid_from', CAST('2023-08-20' AS DATETIME2) 
    UNION 
        select 1337 as material_id, 'A' as 'material_name', CAST('2023-08-20' AS DATETIME2) AS 'valid_from', CAST('2100-12-13' AS DATETIME2) 
    UNION 
    SELECT 1234, 'B', CAST('2023-08-01' AS DATETIME2), CAST('2023-08-02' AS DATETIME2)
        UNION 
    SELECT 1234, 'B', CAST('2023-08-02' AS DATETIME2), CAST('2023-08-03' AS DATETIME2)
        UNION 
    SELECT 1234, 'BB', CAST('2023-08-03' AS DATETIME2), CAST('2023-08-20' AS DATETIME2)
        UNION 
    SELECT 1234, 'BB', CAST('2023-08-20' AS DATETIME2), CAST('2100-12-13' AS DATETIME2) 
)


SELECT * FROM invoice inv 
LEFT JOIN  materials mat  ON inv.material_id = mat.material_id /* material_id has to match*/
AND ((inv.date_inserted >= mat.valid_from and inv.date_inserted < mat.valid_to) /*either the date_inserted_date matches a valid period from the material */
    OR (inv.date_inserted < mat.valid_from and mat.valid_from = (SELECT min(valid_from) FROM materials mat2 WHERE mat2.material_id = mat.material_id)) /* else, if date_inserted is smaller than all valid_froms, use the first entry for the material*/
    )