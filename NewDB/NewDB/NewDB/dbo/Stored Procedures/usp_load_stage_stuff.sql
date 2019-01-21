-- Standard Sproc 
CREATE   PROCEDURE dbo.usp_load_stage_stuff  --INSERT PROC NAME HERE
-- Parameterized Sproc 
-- CREATE PROCEDURE dbo.usp_<load>_<stage|edw>_<target> @PARAM1 INT = NULL, @PARAM2 VARCHAR(30) = NULL
-- 
AS
 
/* ----------------------------------------------------------------------------------
Author:  Shannon Koontz
Creation Date: 12.13.18
Desc: Stored Proc Template for Data Acquisision, ETL. 
Note: Please do a find/replace on <tablename> for target table name
-------------------------------------------------------------------------------------
  Sample Execution: EXEC --INSERT PROC NAME AND PARAMETERS HERE
-------------------------------------------------------------------------------------
Change History
DATE            CHANGED BY      JIRA ITEM       CHANGE DESCRIPTION
12/13/2018      Shannon.koontz  GARS-123        Created Basic Template 
*/
----------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------

-- Logical processing handling variables
        DECLARE @ProcName VARCHAR(128) = ''
            , @StartTime DATETIME2 = GETDATE(), @I INT = 0, @SQL NVARCHAR(MAX) = N''
        -- For error handling portion of try/catch block
            , @ERROR_NUMBER INT, @ERROR_MESSAGE NVARCHAR(4000), @ERROR_SEVERITY INT, @ERROR_STATE INT
        -- Information logging for Event Log
            , @Inserted INT = 0, @Updated INT = 0, @Deleted INT = 0, @Rows INT = 0 
        -- For logging performance statistics
            , @Reads INT = 0, @Writes INT = 0, @Logical_Reads INT = 0, @CPU_Time INT

BEGIN TRY  
 
/*INSERT CODE HERE*/
    -- BEGIN TRANSACTION
    -- COMMIT TRANSACTION
     	
/* Logging Query performance statistics */
        SELECT @CPU_Time = CPU_Time, @Reads = reads, @Writes = writes, @Logical_Reads = logical_reads
        FROM sys.dm_exec_requests WITH(NOLOCK) 
        WHERE session_id = @@SPID        

----------------------------------------------------------------------------------
-- Update Log table with information 
----------------------------------------------------------------------------------
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

END TRY
BEGIN CATCH
    SELECT @ERROR_NUMBER = ERROR_NUMBER(), @ERROR_SEVERITY = ERROR_SEVERITY(), @ERROR_STATE = ERROR_STATE(), @ERROR_MESSAGE = ERROR_MESSAGE()

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

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
        , @ERROR_NUMBER = @ERROR_NUMBER
        , @ERROR_SEVERITY = @ERROR_SEVERITY
        , @ERROR_STATE = @ERROR_STATE
        , @ERROR_MESSAGE = @ERROR_MESSAGE

		RETURN
 
END CATCH