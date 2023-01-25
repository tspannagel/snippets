CREATE TABLE maskingDemo(
    id NVARCHAR(36) NOT NULL PRIMARY KEY CLUSTERED
    ,fullName NVARCHAR(100) MASKED WITH (FUNCTION ='default()')
    ,mail NVARCHAR(100) MASKED WITH (FUNCTION='email()')
    ,salary FLOAT MASKED WITH (FUNCTION = 'random(1,100)')
    ,descr NVARCHAR(100) MASKED WITH (FUNCTION='partial(1,"[...]",2)')
)
GO
INSERT INTO maskingDemo (id, fullname, mail, salary,descr) VALUES
(NEWID(), 'donald duck', 'donald@duck.com', 0.54, 'A talking duck!'),
(NEWID(), 'mickey mouse', 'mickey@mouse.com', 234.54, 'A talking mouse! married to minnie' ),
(NEWID(), 'minnie mouse', 'minnie@mouse.com', 432.54,'A talking mouse! married to mickey'),
(NEWID(), 'dagobert duck', 'dagobert@duck.com', 56823637.99, 'A rich, talking duck!')
GO
CREATE VIEW vMaskingDemo AS 
    SELECT
        id 
        ,LEFT(fullName, CHARINDEX(' ', fullname)) AS FirstName 
        ,RIGHT(fullName, LEN(fullName) - CHARINDEX(' ', fullname)) AS LastName 
        ,mail
        ,salary*12 as 'yearlySalary'
    FROM maskingDemo

GO

CREATE USER batman WITHOUT LOGIN
CREATE USER bruceWayne WITHOUT LOGIN
GO
GRANT SELECT ON maskingDemo to batman
GRANT SELECT ON maskingDemo to bruceWayne
GRANT SELECT ON vMaskingDemo to batman
GRANT SELECT ON vMaskingDemo to bruceWayne
GRANT UNMASK TO bruceWayne
GO
EXECUTE AS USER = 'batman'
SELECT *, CURRENT_USER AS 'executedAs' FROM maskingDemo
SELECT *,CURRENT_USER AS 'executedAs' FROM vMaskingDemo
REVERT;
EXECUTE AS USER = 'bruceWayne'
SELECT *,CURRENT_USER AS 'executedAs' FROM maskingDemo
SELECT *,CURRENT_USER AS 'executedAs' FROM vMaskingDemo
REVERT;

DROP USER batman
DROP USER bruceWayne
DROP TABLE maskingDemo
DROP VIEW vMaskingDemo