
CREATE PROCEDURE dbo.usp_Log_Pipeline_Info @ProcName VARCHAR(128), @Watermark NVARCHAR(100), @LastLoad DATETIME
AS
BEGIN

    UPDATE MPO
        Set HighestWatermark = @Watermark
        ,LastLoad = @LastLoad
    FROM dbo.Master_Pipeline_Orchestration as MPO
    WHERE ProcedureName = @ProcName 

END