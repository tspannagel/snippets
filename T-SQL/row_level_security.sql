-- docs: https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security?view=sql-server-ver16

-- create seperate schema for security policies/predicates as recommended in best practices
CREATE SCHEMA [security] 
GO
--create demo table with "sensitive" information and employee hierarchy
CREATE TABLE dbo.salaries(
    employeeId INT IDENTITY(1,1) PRIMARY KEY
    ,employeeName VARCHAR(25)
    ,department VARCHAR(25)
    ,position VARCHAR(25)
    ,salary FLOAT
)

CREATE TABLE dbo.hierarchies(
    hierarchyId INT IDENTITY(1,1) PRIMARY KEY
    ,employeeId NVARCHAR(25)
    ,managerId NVARCHAR(25)
)


-- insert demo values
INSERT INTO salaries (employeeName, department, position, salary)
VALUES
('bruce wayne', 'development', 'software engineer', 100000 ),
('tony stark', 'development', 'senior software engineer', 250000),
('tony stark', 'back office', 'specialist', 100000),
('nick fury', 'development', 'manager', 1)
GO

INSERT INTO hierarchies(employeeId, managerId)
VALUES
('bruce wayne','nick fury'),
('tony stark','nick fury')

-- create matching users to the inserted values and grant selects 
CREATE USER [bruce_wayne] WITHOUT LOGIN;
CREATE USER [tony_stark] WITHOUT LOGIN;
CREATE USER [nick_fury] WITHOUT LOGIN;
GO

CREATE ROLE [app_employee];
CREATE ROLE [app_manager];
GO
GRANT SELECT ON dbo.salaries TO [bruce_wayne] 
GRANT SELECT ON dbo.salaries TO [tony_stark]
GRANT SELECT ON dbo.salaries TO [nick_fury]
GO

ALTER ROLE [app_employee] ADD MEMBER [bruce_wayne] 
ALTER ROLE [app_employee] ADD MEMBER [tony_stark] 
ALTER ROLE [app_manager] ADD MEMBER [nick_fury]
GO
-- create security filter function
CREATE FUNCTION [security].[fn_salariesPredicate](@username AS VARCHAR(25))
RETURNS TABLE 
WITH SCHEMABINDING
AS 
RETURN 
    SELECT 1 AS grantAccess
        WHERE @username = REPLACE(USER_NAME(),'_', ' ') OR IS_ROLEMEMBER('app_manager') = 1

GO

CREATE SECURITY POLICY [security].[salariesFilter]
ADD FILTER PREDICATE [security].[fn_salariesPredicate](employeeName)
ON dbo.salaries
WITH(STATE = ON);

GO

SELECT USER_NAME(),* FROM salaries

EXECUTE AS USER = 'bruce_wayne'
SELECT * FROM salaries
REVERT;

EXECUTE AS USER = 'tony_stark'
SELECT * FROM salaries
REVERT;

EXECUTE AS USER = 'nick_fury'
SELECT * FROM salaries
REVERT;
GO

-- cleanupDROP USER [bruce_wayne]

DROP USER [bruce_wayne]
DROP USER [tony_stark]
DROP USER [nick_fury]
DROP SECURITY POLICY [security].[salariesFilter]
DROP FUNCTION [security].[fn_salariesPredicate]
DROP TABLE [salaries]
DROP TABLE [hierarchies]
DROP SCHEMA [security]
DROP ROLE [app_employee]
DROP ROLE [app_manager]

SELECT GETDATE(), DATETRUNC(day, GETDATE())