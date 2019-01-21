CREATE TABLE [dbo].[Dimensional_Table] (
    [DimKey]     INT           IDENTITY (1, 1) NOT NULL,
    [NaturalKey] INT           NULL,
    [COL1]       VARCHAR (128) NULL,
    [COL2]       VARCHAR (128) NULL,
    [CreatedOn]  DATETIME      NULL,
    [UpdatedOn]  DATETIME      NULL,
    [Hashkey]    INT           NULL,
    PRIMARY KEY CLUSTERED ([DimKey] ASC)
);

