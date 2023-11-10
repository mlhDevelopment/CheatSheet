# Query Notes

## General Queries

### SQLCMD using username & password, run an inline query

    sqlcmd -S server -U testuser -P password -d dbname -Q "select * from query"

### SQLCMD using Windows auth, run a script

    sqlcmd -S server -E -d dbname -i $(gcb)

### Export SQL via PowerShell SQLCMD

    Invoke-Sqlcmd -ServerInstance server -Database dbname -Query "SELECT * FROM query" | Export-Csv C:\etc\out.csv

### Test a temp table

    IF OBJECT_ID('tempdb..#tmpName') IS NOT NULL DROP TABLE #tmpName
    TRY DROP TABLE #tmpName END TRY CATCH END CATCH

### Search the definition of a sproc

    SELECT DISTINCT sys.schemas.name AS SchemaName, sys.objects.name AS ProcName
    FROM sys.objects
        JOIN sys.schemas
            ON sys.objects.schema_id = sys.schemas.schema_id
        JOIN sys.syscomments
            ON sys.objects.object_id = sys.syscomments .id
    WHERE sys.objects.type = 'p' -- Filters below here
    --  AND sys.objects.name LIKE 'usp%'
    --  AND sys.objects.name NOT LIKE 'rpt%'
        AND sys.syscomments.[text] LIKE '%EMAIL%'

## CSV

### Use XML for CSV listing

```sql
SELECT STUFF(
    (SELECT ', ' + columnname
    FROM tablename
    FOR XML PATH(''))
    , 1, 2, '')
```

### Use XML for CSV listing, more complicated example

```sql
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(STUFF(
    (SELECT 'pre' + columnname + 'post'
    FROM tablename WITH (NOLOCK)
    FOR XML PATH(''))
    , 1, 3, ''), '&lt;', '<'), '&gt;', '>'), '&amp;', '&'), '&#x0D;', CHAR(13)), '&#x0A;', CHAR(10)) AS csv
```

### Use XML for CSV column, correlated with another table

```sql
SELECT Id, Values =
    STUFF((SELECT ', ' + Value
    FROM table2
    WHERE table2.ParentId = table1.Id
    FOR XML PATH(''))
    , 1, 2, '')
FROM table1
```

## XML

### Query XML variable

    SELECT X.el.value('y[1]', 'int') as id FROM @xml.nodes('//z') AS X(el);

### Query XML variable with a namespace

    WITH XMLNAMESPACES ('http://schemas.microsoft.com/developer/msbuild/2003' AS x)
    SELECT a.b.value('@Include', 'varchar(100)') FROM @xml.nodes('//x:Build') AS a(b);

### Query XML column

    SELECT xmlcol.query('/RootEl[1]/ChildEl[1]') from tablename

### Query XML column that contains repeated elements

    SELECT DISTINCT tablename.idcolumn, b.value('text()[1]', 'varchar(5)') as c
    FROM tablename
        CROSS APPLY xmlcol.nodes('/RootEl/ChildEl') AS a(b)
    WHERE xmlcol IS NOT NULL

### Convert to/from XML

    SELECT [@att] = Col1 FROM tblX FOR XML PATH('Children'), ROOT('Parent')
    <Parent><Children att="Col1Value" /><Children att="Col1Value" /></Parent>

TODO: For xml raw, elements, root('rows') -- `<rows><row><Col1>...</Col1><Col2>...</Col2></row><row><Col1>...</Col1><Col2>...</Col2></row></rows>`

### Create multi-level XML

    SELECT [@attr] = id,
            [Element_1] = Name,
            [Element_2] = Description, (
        SELECT 
            [@attr] = id,
            [Element_A] = ChildName,
            [Element_B] = ChildDescription
        FROM tablename2
        WHERE tablename2.parentid = tablename1.id
        ORDER BY id
        FOR XML PATH('Child'), TYPE
    )
    FROM tablename1
    FOR XML PATH('Parent'), ROOT('Parents'), TYPE

### XML from file

    DECLARE @xml XML;
    SELECT @xml = bulkcolumn FROM OPENROWSET(BULK 'c:\datafile.xml',single_blob) AS b;

### See preview of all tables

    SELECT 'SELECT TOP 3 ''' + TABLE_NAME + 
      ''', * FROM [' + TABLE_SCHEMA + '].[' + TABLE_NAME + ']' AS sql 
    FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'

### List all simple database objects (from INFORMATION_SCHEMA)

          SELECT obj = 'TABLE: ' + table_catalog + '.' + table_schema + '.' + table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE'
    UNION SELECT obj = 'VIEW : ' + table_catalog + '.' + table_schema + '.' + table_name FROM information_schema.tables WHERE table_type <> 'BASE TABLE'
    UNION SELECT obj = 'SPROC: ' + routine_catalog + '.' + routine_schema + '.' + routine_name FROM INFORMATION_SCHEMA.ROUTINES

### Left Pad a field with spaces

    LEFT('                   ', @lenToPad - LEN(_______)) + _______
    RIGHT('                  ' + RTRIM(_______), @lenToPad)

### Generate a sequence ID

    SELECT NEXT VALUE FOR seqSequenceName

### Generate a batch of sequences

    EXEC dbo.sp_sequence_get_range @sequence_name = 'seqSequenceName', @range_size = 1000, @range_first_value = NULL

Useful if the sequence gets reset and needs to be fast forwarded to an existing ID

## Server Management

### Refresh all cached objects on the server (Views, sprocs, etc)

    DBCC FREEPROCCACHE

### Show the last command ran by a spid

    DBCC INPUTBUFFER(<spidId>)

### SP Who 2 Query into temp table for filtering

    IF OBJECT_ID('tempdb..#sp_who2') IS NOT NULL DROP TABLE #sp_who2
    CREATE TABLE #sp_who2 (SPID INT, Status VARCHAR(1000) NULL, LOGIN SYSNAME NULL, HostName SYSNAME NULL, BlkBy SYSNAME NULL, DBName SYSNAME NULL, Command VARCHAR(1000) NULL, CPUTime INT NULL, DiskIO INT NULL, LastBatch VARCHAR(1000) NULL, ProgramNa  VARCHAR(1000) NULL, SPID2 INT, RequestId INT) 
    INSERT INTO #sp_who2 EXEC sp_who2
    SELECT * FROM #sp_who2 WHERE ProgramName LIKE '.Net SqlClient Data Provider%' AND HostName LIKE 'M%'

### Determine the SQL Execute As procedures

    SELECT OBJECT_NAME(object_id) FROM sys.sql_modules WHERE execute_as_principal_id = USER_ID('dbuser')

### Take a database into read only mode

    ALTER DATABASE DBName SET READ_ONLY WITH NO_WAIT

### Take a database into single user mode

    ALTER DATABASE dbname SET SINGLE_USER WITH ROLLBACK IMMEDIATE

### Take a database out of single user mode

    ALTER DATABASE dbname SET MULTI_USER WITH ROLLBACK IMMEDIATE

### Rename a database

    ALTER DATABASE oldName SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    ALTER DATABASE oldName MODIFY NAME = newName
    ALTER DATABASE newName SET MULTI_USER WITH ROLLBACK IMMEDIATE

### Fix incorrect SIDs

    EXEC sp_change_users_login 'auto_fix', 'dbuser'

### Fix incorrect SIDs across all databases

    USE master
    EXEC sys.sp_MSforeachdb @command2='use [?]; exec sp_change_users_login ''auto_fix'', ''dbuser''', @Command1='Print ''Fixing for ?'''

### Create custom alias (e.g. DevLocal)

    EXEC sp_dropserver @@servername, 'droplogins'
    EXEC sp_addserver 'devlocal', 'local'

Then restart the SQL services

### Check how you are connected to a SQL server

    SELECT auth_scheme FROM sys.dm_exec_connections WHERE session_id = @@SPID

### All the running queries in the db, including the individual query (useful for locks)

```sql
BEGIN    -- Do not lock anything, and do not get held up by any locks.
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    -- What SQL Statements Are Currently Running?
    DECLARE @dt DATETIME
    SET @dt = GETDATE()
    ; WITH cteData AS (
        SELECT [Spid] = session_Id,
            BlockingSpid = CASE er.blocking_session_id
                WHEN -2 THEN 'orphaned distributed transaction' 
                WHEN -3 THEN 'deferred recovery transaction' 
                WHEN -4 THEN 'NA due to internal latch state transactions'
                WHEN 0 THEN ' . '
                ELSE CAST(er.blocking_session_id AS VARCHAR(250)) END,
            ecid,
            db = DB_NAME(sp.dbid),
            --NtUser = nt_username,
            [Status] = er.status, 
            [Wait] = wait_type,
            Cmd = Command, 
            StartTime = start_time,
            ElapsedMsRaw = DATEDIFF(ms, start_time, @dt),
            [Query] = SUBSTRING (qt.text, 
                er.statement_start_offset/2,
                (CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                    ELSE er.statement_end_offset END - 
                    er.statement_start_offset)/2),
            ParentQuery = qt.text,
            Program = program_name,
            Hostname, 
            nt_domain
        FROM sys.dm_exec_requests er
            INNER JOIN sys.sysprocesses sp 
                ON er.session_id = sp.spid
            CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as qt
        WHERE session_Id > 50              -- Ignore system spids.
            AND session_Id NOT IN (@@SPID) -- Ignore this current statement.
    )
    SELECT [Spid], BlockingSpid, ThreadCount = COUNT(*), db, --NtUser,
        [Status], [Wait], Cmd, StartTime, 
        ElapsedMs = REPLACE(CONVERT(VARCHAR, CAST(ElapsedMsRaw AS MONEY), 1), '.00', ''),
        ElapsedMin = ElapsedMsRaw / 60000,
        [Query], ParentQuery,
        Program, Hostname, nt_domain
    FROM cteData
    GROUP BY [Spid], BlockingSpid, db, --NtUser,
        [Status], [Wait], Cmd, StartTime, ElapsedMsRaw, [Query], ParentQuery,
        Program, Hostname, nt_domain
    ORDER BY ElapsedMsRaw DESC
    --ORDER BY 1, 2, 3
END
```

### Create SQL user with specific SID

    CREATE LOGIN username WITH PASSWORD=N'xxxxxx', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, SID=0xSID0000

### Restore a database (single BAK file)

    RESTORE DATABASE dbname FROM DISK = 'bakfilepath' WITH REPLACE, STATS = 5

### Restore a database (BAK + TRN files)

    RESTORE DATABASE dbname FROM DISK = 'bakfilepath' WITH NORECOVERY, REPLACE, STATS = 5
    RESTORE LOG dbname FROM DISK = 'trnfilepath' WITH NORECOVERY, STATS = 5
    RESTORE LOG dbname FROM DISK = 'lasttrnfilepath' WITH STATS = 5

### Perform BCP (cmd command)

    bcp dbname.dbo.tablename out "C:\tablename dates.dat" -T -c

### Set the owner of a database

    ALTER AUTHORIZATION ON DATABASE::AdventureWorks TO sa;

### Enable failure emails on all jobs

```sql
DECLARE @JobName SYSNAME, @JobID UNIQUEIDENTIFIER, @NotifyLevel INT, @SQL NVARCHAR(3000), @opName VARCHAR(100) = 'myopname'

DECLARE job_operator_cursor CURSOR FOR 
    SELECT name, job_id, notify_level_email FROM msdb.dbo.sysjobs_view 

OPEN job_operator_cursor
FETCH NEXT FROM job_operator_cursor INTO @JobName, @JobID, @NotifyLevel
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS(SELECT 1 FROM msdb.dbo.sysjobs_view WHERE notify_level_email = 2 and name LIKE @JobName)
    BEGIN
        PRINT 'Setting for ' + @JobName
        SELECT @SQL = 'EXEC msdb.dbo.sp_update_job @job_name=N'''+@JobName+''',
        @notify_level_email=2,
        @notify_level_netsend=2,
        @notify_level_page=2,
        @notify_email_operator_name=N''' + @opName + ''''
        EXEC sp_executesql @SQL
    END
    FETCH NEXT FROM job_operator_cursor INTO @JobName, @JobID, @NotifyLevel
END

CLOSE job_operator_cursor
DEALLOCATE job_operator_cursor
```

### Enforce an untrusted constraint

    ALTER TABLE tablename WITH CHECK CHECK CONSTRAINT FK_tablename_columnname

### List untrusted constraints and foreign keys

```sql
SELECT '[' + s.name + '].[' + o.name + '].[' + i.name + ']' AS keyname
FROM sys.check_constraints i
    INNER JOIN sys.objects o 
        ON i.parent_object_id = o.object_id
    INNER JOIN sys.schemas s
        ON o.schema_id = s.schema_id
WHERE i.is_not_trusted = 1 AND i.is_not_for_replication = 0 AND i.is_disabled = 0;
```

### Generate script to enforce all untrusted constraints (executing script may take time!)

```sql
SELECT SchemaName = s.name, TableName = o.name, KeyName = i.name,
    SqlCmd = 'ALTER TABLE [' + s.name + '].[' + o.name + '] WITH CHECK CHECK CONSTRAINT [' + i.name + '];'
FROM sys.foreign_keys i
    INNER JOIN sys.objects o
        ON i.parent_object_id = o.object_id
    INNER JOIN sys.schemas s 
        ON o.schema_id = s.schema_id
WHERE i.is_not_trusted = 1 AND i.is_not_for_replication = 0;
```

### SQL Job Report - Query information about jobs

```sql
SELECT JobName = sysjobs.name, 
    OwnerName = syslogins.Name,
    sysjobs.enabled,
    StepName = sysjobsteps.step_name,
    StepType = sysjobsteps.subsystem,
    StepCommand = sysjobsteps.command,
    ProxyName = sysproxies.name,
    EmailAlert = sysoperators.name,
    Schedule = sysschedules.name
FROM msdb.dbo.sysjobs
    JOIN master.dbo.syslogins
        ON syslogins.SID = sysjobs.owner_sid
    LEFT JOIN msdb.dbo.sysjobsteps
        ON sysjobsteps.job_id = sysjobs.job_id
    LEFT JOIN msdb.dbo.sysproxies
        ON sysjobsteps.proxy_id = sysproxies.proxy_id
    LEFT JOIN msdb.dbo.sysoperators
        ON sysjobs.notify_email_operator_id = sysoperators.id
        AND sysjobs.notify_level_email = 2
    LEFT JOIN msdb.dbo.sysjobschedules
        ON sysjobs.job_id = sysjobschedules.job_id
    LEFT JOIN msdb.dbo.sysschedules
        ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE job.name NOT IN ('syspolicy_purge_history') AND
    job.name NOT LIKE 'MP-%'
ORDER BY sysjobs.name, sysjobsteps.step_id
```

### Jobs that are currently running

```sql
SELECT sysjobs.Name,
    RunStart = sysjobactivity.start_execution_date,
    RunningSeconds = DATEDIFF(SECOND, sysjobactivity.start_execution_date, GETDATE())
FROM msdb.dbo.sysjobs
    JOIN msdb.dbo.sysjobactivity
        ON sysjobs.job_id = sysjobactivity.job_id
WHERE sysjobactivity.start_execution_date IS NOT NULL AND
    sysjobactivity.stop_execution_date IS NULL
ORDER BY sysjobs.Name
```

### Super-query concerning database encrypt

```sql
SELECT SymKeyName = symmetric_keys.name,
    CertName = certificates.name, 
    PrivateKeyEncryptType = certificates.pvt_key_encryption_type_desc,
    DBName = d.name, 
    DBEncryptType = dek.encryptor_type,
    DBCertName = CASE WHEN d.database_id IS NOT NULL THEN certificates.name END
FROM master.sys.symmetric_keys,
    master.sys.certificates
    LEFT JOIN sys.dm_database_encryption_keys dek
        ON dek.encryptor_thumbprint = certificates.thumbprint
    LEFT JOIN sys.databases d
        ON dek.database_id = d.database_id
WHERE symmetric_keys.name = '##MS_DatabaseMasterKey##' AND
    certificates.name NOT LIKE '##%'
```

### Encryption keys and certificates

    SELECT * FROM master.sys.symmetric_keys
    SELECT * FROM master.sys.certificates WHERE name = 'DatabaseEncryption1'

### Encrypted databases and how they are encrypted

```sql
SELECT DBName = d.name, dek.encryptor_type, CertName = c.name
FROM sys.dm_database_encryption_keys dek
    LEFT JOIN sys.certificates c
        ON dek.encryptor_thumbprint = c.thumbprint
    INNER JOIN sys.databases d
        ON dek.database_id = d.database_id;
```

## File and Space Management

### Find file locations and sizes

```sql
SELECT dbName = DB_NAME(database_id), fileName = name, physical_name, SizeGB = CAST((size*8.0)/1024.0/1024.0 AS DECIMAL(9,2))
FROM master.sys.master_files 
WHERE DB_NAME(database_id) NOT IN ('master', 'model', 'msdb')
ORDER BY 1, 2
```

### Grow file size manually

    ALTER DATABASE dbname MODIFY FILE ( NAME = dbname_Data,  SIZE = 10240MB )
    ALTER DATABASE dbname MODIFY FILE ( NAME = dbname_Log ,  SIZE = 1024MB )

### Check space/size by table

```sql
;WITH extra AS
(   -- Get info for FullText indexes, XML Indexes, etc
    SELECT  sit.[object_id],
            sit.[parent_id],
            ps.[index_id],
            SUM(ps.reserved_page_count) AS [reserved_page_count],
            SUM(ps.used_page_count) AS [used_page_count]
    FROM    sys.dm_db_partition_stats ps
    INNER JOIN  sys.internal_tables sit
            ON  sit.[object_id] = ps.[object_id]
    WHERE   sit.internal_type IN
            (202, 204, 207, 211, 212, 213, 214, 215, 216, 221, 222, 236)
    GROUP BY    sit.[object_id],
                sit.[parent_id],
                ps.[index_id]
), agg AS
(   -- Get info for Tables, Indexed Views, etc (including "extra")
    SELECT  ps.[object_id] AS [ObjectID],
            ps.index_id AS [IndexID],
            SUM(ps.in_row_data_page_count) AS [InRowDataPageCount],
            SUM(ps.used_page_count) AS [UsedPageCount],
            SUM(ps.reserved_page_count) AS [ReservedPageCount],
            SUM(ps.row_count) AS [RowCount],
            SUM(ps.lob_used_page_count + ps.row_overflow_used_page_count)
                    AS [LobAndRowOverflowUsedPageCount]
    FROM    sys.dm_db_partition_stats ps
    GROUP BY    ps.[object_id],
                ps.[index_id]
    UNION ALL
    SELECT  ex.[parent_id] AS [ObjectID],
            ex.[object_id] AS [IndexID],
            0 AS [InRowDataPageCount],
            SUM(ex.used_page_count) AS [UsedPageCount],
            SUM(ex.reserved_page_count) AS [ReservedPageCount],
            0 AS [RowCount],
            0 AS [LobAndRowOverflowUsedPageCount]
    FROM    extra ex
    GROUP BY    ex.[parent_id],
                ex.[object_id]
), spaceused AS
(
SELECT  agg.[ObjectID],
        OBJECT_SCHEMA_NAME(agg.[ObjectID]) AS [SchemaName],
        OBJECT_NAME(agg.[ObjectID]) AS [TableName],
        SUM(CASE
                WHEN (agg.IndexID < 2) THEN agg.[RowCount]
                ELSE 0
            END) AS [Rows],
        SUM(agg.ReservedPageCount) * 8 AS [ReservedKB],
        SUM(agg.LobAndRowOverflowUsedPageCount +
            CASE
                WHEN (agg.IndexID < 2) THEN (agg.InRowDataPageCount)
                ELSE 0
            END) * 8 AS [DataKB],
        SUM(agg.UsedPageCount - agg.LobAndRowOverflowUsedPageCount -
            CASE
                WHEN (agg.IndexID < 2) THEN agg.InRowDataPageCount
                ELSE 0
            END) * 8 AS [IndexKB],
        SUM(agg.ReservedPageCount - agg.UsedPageCount) * 8 AS [UnusedKB],
        SUM(agg.UsedPageCount) * 8 AS [UsedKB]
FROM    agg
GROUP BY    agg.[ObjectID],
            OBJECT_SCHEMA_NAME(agg.[ObjectID]),
            OBJECT_NAME(agg.[ObjectID])
)
SELECT sp.SchemaName,
    sp.TableName,
    sp.[Rows],
    sp.ReservedKB,
    (sp.ReservedKB / 1024.0 / 1024.0) AS [ReservedGB],
    sp.DataKB,
    (sp.DataKB / 1024.0 / 1024.0) AS [DataGB],
    sp.IndexKB,
    (sp.IndexKB / 1024.0 / 1024.0) AS [IndexGB],
    sp.UsedKB AS [UsedKB],
    (sp.UsedKB / 1024.0 / 1024.0) AS [UsedGB],
    sp.UnusedKB,
    (sp.UnusedKB / 1024.0 / 1024.0) AS [UnusedGB],
    so.[type_desc] AS [ObjectType],
    so.[schema_id] AS [SchemaID],
    sp.ObjectID
FROM   spaceused sp
INNER JOIN sys.all_objects so
    ON so.[object_id] = sp.ObjectID
WHERE so.is_ms_shipped = 0
ORDER BY sp.DataKB DESC
```

### Check space for a single database

    EXEC sp_spaceused

### Check autogrowth remaining space for a single database

```sql
SELECT 
    [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0)
    ,[USEDSPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
    ,[AutoGrow] = 'By ' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + ' MB -' 
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + '% -' ELSE '' END 
        + CASE max_size WHEN 0 THEN 'DISABLED' WHEN -1 THEN ' Unrestricted' 
            ELSE ' Restricted to ' + CAST(max_size/(128*1024) AS VARCHAR(10)) + ' GB' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
ORDER BY A.TYPE desc, A.NAME;
```

### List autogrowth remaining space for all databases

```sql
EXEC master.sys.sp_MSforeachdb 'USE [?]; SELECT Db=''[?]'', [Type] = A.TYPE_DESC, FileName = A.name, FileGroup = fg.name, FileLocation = A.PHYSICAL_NAME,
    FileSizeMB = CONVERT(DECIMAL(10,2),A.SIZE/128.0), UsedSpaceMB = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)),
    FreeSpaceMB = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0),
    FreeSpacePct = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0)/(A.SIZE/128.0))*100),
    AutoGrow = ''By '' + CASE is_percent_growth WHEN 0 THEN CAST(growth/128 AS VARCHAR(10)) + '' MB -''
        WHEN 1 THEN CAST(growth AS VARCHAR(10)) + ''% -'' ELSE '''' END 
        + CASE max_size WHEN 0 THEN ''DISABLED'' WHEN -1 THEN '' Unrestricted'' 
            ELSE '' Restricted to '' + CAST(max_size/(128*1024) AS VARCHAR(10)) + '' GB'' END
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
ORDER BY A.TYPE desc, A.NAME;'
```

### Shrink Database (not beneficial in production; also truncates log file)

    DBCC SHRINKDATABASE('dbname')

### Check index fragmentation

```sql
SELECT object_name(dt.object_id) Tablename,si.name
    IndexName,dt.avg_fragmentation_in_percent AS
    ExternalFragmentation,dt.avg_page_space_used_in_percent AS
    InternalFragmentation
FROM
(
    SELECT object_id,index_id,avg_fragmentation_in_percent,avg_page_space_used_in_percent
    FROM sys.dm_db_index_physical_stats (db_id('AdventureWorks'),null,null,null,'DETAILED'
)
WHERE index_id <> 0) AS dt INNER JOIN sys.indexes si ON si.object_id=dt.object_id
AND si.index_id=dt.index_id AND dt.avg_fragmentation_in_percent>10
AND dt.avg_page_space_used_in_percent<75 ORDER BY avg_fragmentation_in_percent DESC
```

### Index fragmentation using a stored procedure for speed

```sql
CREATE PROCEDURE dbo.usp_IndexFragmentation
    @refreshStats BIT = 0,
    @externalFragMin FLOAT = 10,
    @internalFragMax FLOAT = 75
AS BEGIN
    
    IF @refreshStats = 1
    BEGIN
        TRUNCATE TABLE IndexPhysicalStats

        INSERT INTO IndexPhysicalStats(object_id, index_id, avg_fragmentation_in_percent, avg_page_space_used_in_percent)
        SELECT object_id,
            index_id,
            avg_fragmentation_in_percent,
            avg_page_space_used_in_percent
        FROM sys.dm_db_index_physical_stats(DB_ID(),null,null,null,'DETAILED')
        WHERE index_id <> 0
    END

    SELECT object_name(IndexPhysicalStats.object_id) AS Tablename,
        si.name
        IndexName,
        IndexPhysicalStats.avg_fragmentation_in_percent AS ExternalFragmentation,
        IndexPhysicalStats.avg_page_space_used_in_percent AS InternalFragmentation
    FROM IndexPhysicalStats
        JOIN sys.indexes si 
            ON si.object_id = IndexPhysicalStats.object_id
            AND si.index_id = IndexPhysicalStats.index_id
            AND IndexPhysicalStats.avg_fragmentation_in_percent > @externalFragMin
            AND IndexPhysicalStats.avg_page_space_used_in_percent < @internalFragMax
    ORDER BY avg_fragmentation_in_percent DESC  
END
```

### Determine VLF count for all databases

```sql
DECLARE @query varchar(1000), @dbname varchar(1000), @count INT
SET NOCOUNT ON
DECLARE csr CURSOR FAST_FORWARD READ_ONLY FOR
    SELECT name FROM sys.databases
CREATE TABLE ##loginfo ( dbname varchar(100), num_of_rows int )
OPEN csr
    FETCH NEXT FROM csr INTO @dbname
    WHILE (@@fetch_status <> -1)
    BEGIN
        CREATE TABLE #log_info (RecoveryUnitId tinyint, fileid tinyint, file_size bigint, start_offset bigint, FSeqNo int, [status] tinyint, parity tinyint, create_lsn numeric(25,0))
        SET @query = 'DBCC loginfo (' + '''' + @dbname + ''') '
        INSERT INTO #log_info EXEC (@query)
        SET @count = @@rowcount
        DROP TABLE #log_info
        INSERT ##loginfo VALUES(@dbname, @count)
        FETCH NEXT FROM csr INTO @dbname
    END
CLOSE csr
DEALLOCATE csr

SELECT dbname, num_of_rows 
FROM ##loginfo
WHERE num_of_rows >= 50 --My rule of thumb is 50 VLFs. Your mileage may vary.
ORDER BY 2 desc

DROP TABLE ##loginfo
```

### Shrink and expand log files to reduce VLFs

```sql
USE DBname
DECLARE @file_name sysname, @file_size int, @file_growth int, @shrink_command nvarchar(max), @alter_command nvarchar(max)

SELECT @file_name = name, @file_size = (size / 128)
FROM sys.database_files
WHERE type_desc = 'log'

RAISERROR('Shrinking/expanding %s to %i MB', 16, 1, @file_name, @file_size) WITH NOWAIT

SELECT @shrink_command = 'DBCC SHRINKFILE (N''' + @file_name + ''' , 0, TRUNCATEONLY)'
PRINT @shrink_command
EXEC sp_executesql @shrink_command

SELECT @shrink_command = 'DBCC SHRINKFILE (N''' + @file_name + ''' , 0)'
PRINT @shrink_command
EXEC sp_executesql @shrink_command

SELECT @alter_command = 'ALTER DATABASE [' + db_name() + '] MODIFY FILE (NAME = N''' + @file_name + ''', SIZE = ' + CAST(@file_size AS nvarchar) + 'MB)'
PRINT @alter_command
EXEC sp_executesql @alter_command
```

### Check recovery mode ()

    SELECT name, recovery_model_desc FROM sys.databases

### Change recovery mode

    ALTER DATABASE [db_name] SET RECOVERY SIMPLE

### Truncate just the log file (not beneficial in production when full recovery is active)

    ALTER DATABASE dbname SET RECOVERY SIMPLE
    DBCC SHRINKFILE (dbname_Log)
