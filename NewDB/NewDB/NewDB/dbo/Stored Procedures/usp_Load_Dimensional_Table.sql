CREATE   PROCEDURE dbo.usp_Load_Dimensional_Table
AS 
BEGIN 

	----------------------------------------------------------------------------------
	-- Setup
	----------------------------------------------------------------------------------
	DECLARE
		-- Logical processing handling variables
		@ProcName varchar(128) = 'usp_Load_Dimensional_Table', @InsertCheck INT
		-- Information logging for EventLog
		, @Inserted INT = 0, @Updated INT = 0, @Deleted INT = 0, @StartTime DATETIME2 = GETDATE()
		-- For logging performance statistics
		, @Reads INT = 0, @Writes INT = 0, @Logical_Reads INT = 0, @Cpu_Time INT
		-- For error handling portion of try/catch block
		, @ERROR_NUMBER INT, @ERROR_MESSAGE NVARCHAR(4000), @ERROR_SEVERITY INT, @ERROR_STATE INT


	BEGIN TRY
	----------------------------------------------------------------------------------
	-- Beginning of Error handling and data processing
	----------------------------------------------------------------------------------
	/* Checking if table is empty for initial load or not */ 

		SELECT @InsertCheck = (SELECT COUNT(*) FROM dbo.Dimensional_Table) 

	/* Creates Empty Work Replica Table */ 

		DROP TABLE IF EXISTS #Dimensional_Table 
		SELECT top 0 NaturalKey, COL1, COL2, CreatedOn INTO #Dimensional_Table 
		FROM dbo.Dimensional_Table 

	/* Determine Inserts - this is your core insert statement for the table load */ 

		INSERT INTO #Dimensional_Table -- INTO is just for you Ian :) 
		(NaturalKey, COL1, COL2) 
		SELECT 
			st.NaturalKey, st.COL1, st2.COL2
		FROM dbo.SourceTable1 as ST 
			INNER JOIN dbo.SourceTable2 as ST2
				on st.NaturalKey = st2.NaturalKey
		LEFT JOIN dbo.Dimensional_Table as Trg 
			ON Trg.NaturalKey = ST.NaturalKey 
		-- @InsertCheck should insert the whole table if the target is empty
		WHERE Trg.NaturalKey IS NULL

		SELECT @Inserted = @@ROWCOUNT
	
	/* Determine Updates */

		INSERT INTO #Dimensional_Table -- INTO is just for you Ian :) 
		(NaturalKey, COL1, COL2, CreatedOn) 
		SELECT 
			ST.NaturalKey, st.COL1, st2.COL2, Trg.CreatedOn
		FROM dbo.SourceTable1 as ST 
			INNER JOIN dbo.SourceTable2 as ST2
				on st.NaturalKey = st2.NaturalKey
		INNER JOIN dbo.Dimensional_Table as Trg 
			ON Trg.NaturalKey = ST.NaturalKey 
		WHERE (@InsertCheck = 0 OR Trg.HashKey != BINARY_CHECKSUM(st.COL1, st2.COL2))
		-- On initial load, the 0 stops this pretty much from executing. 

		SELECT @Updated = @@ROWCOUNT

	/* Loading into Target Table */

		BEGIN TRANSACTION 

			/* Insert to target table */

				UPDATE Trg
				SET 
					Trg.COL1 = Src.COL1 
					,Trg.COL2 = Src.COL2
					,Trg.HashKey =  BINARY_CHECKSUM(Src.COL1, Src.COL2) 
					,Trg.UpdatedOn = Getdate()
				FROM dbo.Dimensional_Table AS Trg
					INNER JOIN #Dimensional_Table AS Src 
						ON Trg.NaturalKey = Src.NaturalKey

			/* Insert to target table */

				INSERT INTO dbo.Dimensional_Table
				(NaturalKey, COL1, COL2, CreatedOn, HashKey) 
				SELECT NaturalKey, COL1, COL2, getdate(), BINARY_CHECKSUM(COL1, COL2)				
				FROM #Dimensional_Table
				WHERE CreatedOn IS NULL 

		COMMIT 

	/* Logging Query performance statistics */
		SELECT @Cpu_Time = cpu_time, @Reads = reads, @writes = writes, @Logical_Reads = logical_reads
		FROM sys.dm_exec_requests WITH(NOLOCK) 
		WHERE session_id = @@SPID

	----------------------------------------------------------------------------------
	-- Update Log table with information 
	----------------------------------------------------------------------------------
		INSERT INTO Audit_EventLog (Target, TimeStart, TimeEnd, DurationInSeconds, InsertedRecords, UpdatedRecords, DeletedRecords, RowsInTable, Cpu_time, Reads, Writes, Logical_reads)
		SELECT Target = @ProcName, TimeStart = @StartTime, TimeEnd = GETDATE(), DurationInSeconds = CONVERT(DECIMAL(9, 4), DATEDIFf(ms, @StartTime, GETDATE()) / 1000.00), InsertedRecords = @Inserted, UpdatedRecords = @Updated, DeletedRecords = @Deleted, RowsInTable = (
				SELECT COUNT(*)
				FROM dbo.Dimensional_Table WITH(NOLOCK) 
				), cpu_time = @Cpu_Time, reads = @Reads, writes = @writes, logical_reads = @Logical_Reads
	
	END TRY 
	----------------------------------------------------------------------------------
	-- Error handling portion of script
	----------------------------------------------------------------------------------
	BEGIN CATCH
		SELECT @ERROR_NUMBER = ERROR_NUMBER(), @ERROR_MESSAGE = ERROR_MESSAGE(), @ERROR_SEVERITY = ERROR_SEVERITY(), @ERROR_STATE = ERROR_STATE()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		INSERT Audit_EventLog (Target, TimeStart, TimeEnd, DurationInSeconds, InsertedRecords, UpdatedRecords, DeletedRecords, RowsInTable, ErrorMessage, Cpu_time, Reads, Writes, Logical_reads)
		SELECT Target = @ProcName, TimeStart = @StartTime, TimeEnd = GETDATE(), DurationInSeconds = CONVERT(DECIMAL(9, 4), DATEDIFF(ms, @StartTime, GETDATE()) / 1000.00), InsertedRecords = @Inserted, UpdatedRecords = @Updated, DeletedRecords = @Deleted, RowsInTable = (
				SELECT COUNT(*)
				FROM dbo.Dimensional_Table WITH(NOLOCK) 
				), ErrorMessage = @Error_Message, cpu_time, reads, writes, logical_reads
		FROM sys.dm_exec_requests WITH(NOLOCK) 
		WHERE session_id = @@SPID

		RETURN
	END CATCH
END