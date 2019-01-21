CREATE TABLE [dbo].[Audit_EventLog] (
    [EventLogKey]       INT            IDENTITY (1, 1) NOT NULL,
    [Target]            VARCHAR (128)  NULL,
    [TimeStart]         DATETIME       NULL,
    [TimeEnd]           DATETIME       NULL,
    [DurationInSeconds] DECIMAL (9, 4) NULL,
    [InsertedRecords]   INT            NULL,
    [UpdatedRecords]    INT            NULL,
    [DeletedRecords]    INT            NULL,
    [RowsInTable]       INT            NULL,
    [Cpu_time]          INT            NULL,
    [Reads]             INT            NULL,
    [Writes]            INT            NULL,
    [Logical_reads]     INT            NULL,
    [Error_Number]      INT            NULL,
    [Error_Severity]    INT            NULL,
    [Error_State]       INT            NULL,
    [ErrorMessage]      VARCHAR (MAX)  NULL,
    PRIMARY KEY CLUSTERED ([EventLogKey] ASC)
);

