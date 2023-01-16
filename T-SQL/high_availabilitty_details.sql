SELECT IsPrimaryReplica
    , CASE 
        WHEN DATABASEPROPERTYEX('master', 'Updateability') = 'READ_ONLY'
            THEN 1
        ELSE 0
        END AS IsHAReplica
    , LocallyVisibleHAReplicas
    , CASE 
        WHEN GeoPartnerName IS NOT NULL
            AND ReplicaRole != 0
            THEN 1
        ELSE 0
        END AS IsGeoReplica
    , CASE 
        WHEN GeoPartnerName IS NOT NULL
            AND ReplicaRole = 0
            THEN 1
        ELSE CASE 
                WHEN GeoPartnerName IS NULL
                    AND ReplicaRole IS NULL
                    THEN NULL
                ELSE 0
                END
        END AS IsGeoReplicated
FROM (
    SELECT MAX(CAST(is_primary_replica AS INT)) AS IsPrimaryReplica
        , MAX(ROLE) AS ReplicaRole
        , MAX(partner_server) AS GeoPartnerName
        , SUM(CASE 
                WHEN is_primary_replica = 0
                    AND is_commit_participant = 1
                    THEN 1
                ELSE 0
                END) AS LocallyVisibleHAReplicas
    FROM sys.dm_hadr_database_replica_states rs
    LEFT JOIN sys.dm_hadr_fabric_continuous_copy_status fgc
        ON rs.group_id = fgc.physical_database_id
    WHERE rs.database_id = (
            SELECT ISNULL(MAX(maxsrc.database_id), 4)
            FROM sys.dm_hadr_database_replica_states maxsrc
            WHERE maxsrc.database_id BETWEEN 5 AND 32759
            )
    ) src;