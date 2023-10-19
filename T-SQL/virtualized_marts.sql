;WITH products as (
    select '01' as artNo, 'product X' as 'productName', 'shirts' as category
    UNION 
    select '02', 'product Y', 'pants'
    UNION 
    select '03', 'product Z', 'jackets'
),
sales as (    
    select '01' as art_no, 23.65 AS 'amount' -- matches products entry
    UNION
    select '02', 786.65 -- matches products entry
    UNION
    select '04', 2453.12 -- early arriving fact
    UNION
    select '5', 673.12  -- matches articles entry
    UNION
    select '1' as art_no, 65.23 AS 'amount' -- matches articles entry
    UNION
    select '6' as art_no, 23.12 AS 'amount' -- early arriving fact
    UNION    
    select '03', 28.4
    UNION    
    select NULL, 28.467 -- misisng business key
    UNION    
    select NULL, 1548.467  -- misisng business key
),
articles as(    
    select 5 as articleNumber, 'article A' as 'artName'
    UNION 
    select 1, 'article B'
),/* define dimension --> create view as*/
dimArticle as ( 
    SELECT ROW_NUMBER() OVER (ORDER BY artNo) as 'article_id'
    , artNo as 'article_number'
    , productName as 'article_name'
    , category as 'article_category' FROM(
        SELECT artNo, productName, category FROM products
        UNION ALL 
        SELECT CAST(articleNumber AS VARCHAR(2)), artName, 'default category' FROM articles b 
        WHERE CAST(b.articleNumber AS VARCHAR(2)) NOT IN (SELECT artNo FROM products) 
    ) baseDim
    UNION 
    select -99, '-99', 'no key in facts', '-99'
    UNION 
    select -98, '-98', 'early arriving fact', '-98'
)/* define facts --> create view as*/
,factSales as ( 
    SELECT f.amount
    ,COALESCE(d.article_id,-98) as 'article_id'  /* set -98 for early arriving facts*/
    FROM sales f 
    LEFT JOIN dimArticle d on
    d.article_number = COALESCE(f.art_no,'-99') /* join on exact id or replace with -99 for facts with undefined dimension key*/
)
-- SELECT * FROM dimArticle
/*
    general query
*/
/* 
    analyse in sql 
*/
-- SELECT sum(f.amount) as 'Revenue', d.article_category FROM 
-- factSales f INNER JOIN dimArticle d on f.article_id = d.article_id
-- GROUP BY d.article_category
-- ORDER BY article_category
