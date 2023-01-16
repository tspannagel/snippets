-- source: https://www.sqlshack.com/different-ways-to-sql-delete-duplicate-rows-from-a-sql-table/
WITH
    duplicates(
        [FirstName],
        [LastName],
        [Country],
        DuplicateCount
    )
    AS
    (
        SELECT
            [FirstName],
            [LastName],
            [Country],
            ROW_NUMBER() OVER(
            PARTITION BY [FirstName],
            [LastName],
            [Country]
            ORDER BY
                ID
        ) AS DuplicateCount
        FROM
            [SampleDB].[dbo].[Employee]
    )
DELETE FROM
    duplicates
WHERE
    DuplicateCount > 1;