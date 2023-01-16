-- source:https://techcommunity.microsoft.com/t5/azure-sql-blog/how-to-determine-the-timestamp-of-the-last-sql-mi-failover/ba-p/2670361
SELECT sqlserver_start_time AS LastInstanceStart
    , DATEDIFF(HOUR, sqlserver_start_time
    , GETDATE()) AS HoursSinceFailover
FROM sys.dm_os_sys_info;

