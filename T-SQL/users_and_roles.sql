
DECLARE @username NVARCHAR(100) = 'data_engineers'
SELECT  dpu.name As Username
       ,dpu.type_desc AS [User Type]
       ,per.permission_name AS [Permission]
       ,per.state_desc AS [Permission State]
       ,per.class_desc Class
       ,object_name(per.major_id) AS [Object Name]
FROM    sys.database_principals dpu
LEFT JOIN sys.database_permissions per ON per.grantee_principal_id = dpu.principal_id
WHERE name = @username
UNION ALL
SELECT dpu.name,
       dpu.type_desc,
       dpr.name COLLATE SQL_Latin1_General_CP1_CI_AS,
       null,
       dpr.type_desc,
       null
FROM sys.database_role_members drm
INNER JOIN sys.database_principals dpu ON drm.member_principal_id = dpu.principal_id
INNER JOIN sys.database_principals dpr ON drm.role_principal_id = dpr.principal_id 
WHERE dpu.name = @username
