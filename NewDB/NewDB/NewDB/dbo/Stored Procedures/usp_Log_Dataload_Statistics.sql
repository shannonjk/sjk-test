
CREATE PROCEDURE dbo.usp_Log_Dataload_Statistics 
    @Target VARCHAR(128)
    , @StartTime DATETIME2
    , @Inserted INT
    , @Updated INT
    , @Deleted INT
    , @Rows INT
    , @CPU_Time INT
    , @Reads INT
    , @Writes INT
    , @Logical_Reads INT
    , @ERROR_NUMBER INT = null
    , @ERROR_MESSAGE NVARCHAR(4000) = null 
    , @ERROR_SEVERITY INT = null
    , @ERROR_STATE INT = null
AS 
/* ----------------------------------------------------------------------------------
Author:  Shannon Koontz
Creation Date: 12.13.18
Desc: Stored Proc Template for logging data loading statistics 
-------------------------------------------------------------------------------------
  Sample Execution: 
     EXEC dbo.usp_Log_Dataload_Statistics 
        @Target = @ProcName
        , @StartTime = @StartTime
        , @Inserted = @Inserted
        , @Updated = @Updated
        , @Deleted = @Deleted
        , @Rows = @Rows
        , @CPU_Time = @CPU_Time
        , @Reads = @Reads
        , @Writes = @Writes
        , @Logical_Reads = @Logical_Reads 
-------------------------------------------------------------------------------------
Change History
DATE            CHANGED BY      JIRA ITEM       CHANGE DESCRIPTION
12/13/2018      Shannon.koontz  GARS-123        Created Basic Logging script 
*/
----------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------
BEGIN  
    INSERT INTO Audit_EventLog 
        (
        Target
        , TimeStart
        , TimeEnd
        , DurationInSeconds
        , InsertedRecords
        , UpdatedRecords
        , DeletedRecords
        , RowsInTable
        , Cpu_time
        , Reads
        , Writes
        , Logical_reads
        , Error_Number 
        , Error_Severity 
        , Error_State  
        , ErrorMessage 
        
        )
    SELECT 
        Target = @Target
        , TimeStart = @StartTime
        , TimeEnd = GETDATE()
        , DurationInSeconds = CONVERT(DECIMAL(9, 4), DATEDIFf(ms, @StartTime, GETDATE()) / 1000.00)
        , InsertedRecords = @Inserted
        , UpdatedRecords = @Updated
        , DeletedRecords = @Deleted
        , RowsInTable = @Rows
        , cpu_time = @Cpu_Time
        , reads = @Reads
        , writes = @writes
        , logical_reads = @Logical_Reads
        , Error_Number = @Error_Number 
        , Error_Severity = @Error_Severity
        , Error_State  = @Error_State
        , ErrorMessage = @ERROR_MESSAGE
END