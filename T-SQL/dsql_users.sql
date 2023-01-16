WITH sqlUsers AS (
    SELECT * FROM sys.sysusers WHERE issqlrole = 0
),
sqlRoles AS (
    SELECT * FROM sys.sysusers WHERE issqlrole = 1
)
SELECT u.name,u.uid,u.sid,u.islogin, u.hasdbaccess, dp.name, dp.type_desc, dp.authentication_type_desc FROM sqlUsers u
LEFT JOIN sys.database_role_members drm ON u.uid = drm.member_principal_id
LEFT JOIN sys.database_principals dp ON dp.principal_id = drm.role_principal_id
ORDER BY 1