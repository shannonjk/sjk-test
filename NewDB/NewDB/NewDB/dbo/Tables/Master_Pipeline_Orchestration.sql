CREATE TABLE [dbo].[Master_Pipeline_Orchestration] (
    [ProcedureName]    VARCHAR (128)  NULL,
    [HighestWatermark] NVARCHAR (100) NULL,
    [LastLoad]         DATETIME       NULL,
    [CurrentState]     BIT            NULL,
    [Active]           BIT            NULL,
    [ProcessingOrder]  TINYINT        NULL,
    [LoadScript]       NVARCHAR (MAX) NULL
);

