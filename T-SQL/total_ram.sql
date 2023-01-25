SELECT
    cpu_rate / 100 AS CPU_vCores,
    CAST((process_memory_limit_mb) / 1024. AS DECIMAL(9, 1)) AS TotalMemoryGB
FROM sys.dm_os_job_object;
