-- Overview
-- source: https://techcommunity.microsoft.com/t5/azure-sql/how-to-find-out-reserved-and-available-disk-space-on-sql-mi/ba-p/2636930
SELECT TOP 1 reserved_storage_mb
    , storage_space_used_mb
    , CAST((storage_space_used_mb * 100. / reserved_storage_mb) AS DECIMAL(9, 2)) AS [ReservedStoragePercentage]
FROM master.sys.server_resource_stats
ORDER BY end_time DESC;

-- TempDB
-- source: https://techcommunity.microsoft.com/t5/azure-sql/how-to-find-out-reserved-and-available-disk-space-on-sql-mi/ba-p/2636930
IF (
        (
            SELECT TOP 1 SKU
            FROM [sys].[server_resource_stats]
            ORDER BY end_time DESC
            ) = 'GeneralPurpose'
        )
BEGIN
    SELECT vs.volume_mount_point AS VolumeMountPoint
        , CAST(MIN(total_bytes / 1024. / 1024 / 1024) AS NUMERIC(9, 2)) AS LocallyUsedGB
        , CAST(MIN(available_bytes / 1024. / 1024 / 1024) AS NUMERIC(9, 2)) AS LocallyAvailableGB
        , CAST(MIN((total_bytes + available_bytes) / 1024. / 1024 / 1024) AS NUMERIC(9, 2)) AS LocallyTotalGB
    FROM sys.master_files AS f
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) vs
    WHERE UPPER(vs.volume_mount_point) LIKE 'C:\%'
    GROUP BY vs.volume_mount_point;
END

-- Total Space
-- source: https://techcommunity.microsoft.com/t5/azure-sql-blog/how-to-find-out-reserved-and-available-disk-space-on-sql-mi/ba-p/2636930
SELECT SUM(TotalGB) as TotalSpaceGB
	FROM (
	SELECT vs.volume_mount_point as VolumeMountPoint,
		   CAST(MIN(total_bytes / 1024. / 1024 / 1024) AS NUMERIC(9,2)) as UsedGB,
		   CAST(MIN(available_bytes / 1024. / 1024 / 1024) AS NUMERIC(9,2)) as AvailableGB,
		   CAST(MIN((total_bytes+available_bytes) / 1024. / 1024 / 1024) AS NUMERIC(9,2)) as TotalGB
	FROM sys.master_files AS f
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) vs
	GROUP BY vs.volume_mount_point) fsrc;