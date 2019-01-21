
CREATE PROCEDURE dbo.usp_Pull_Pipeline_Info @ProcName VARCHAR(128), @Watermark NVARCHAR(100) OUT, @LoadScript NVARCHAR(1000) OUT
AS
BEGIN
    SELECT @Watermark = HighestWatermark, @LoadScript = LoadScript 
    FROM dbo.Master_Pipeline_Orchestration
    WHERE ProcedureName = @ProcName
END
SELECT @WaterMark, @LoadScript