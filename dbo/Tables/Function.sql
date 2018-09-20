CREATE TABLE [dbo].[Function] (
    [FunctionId]   SMALLINT       IDENTITY (1, 1) NOT NULL,
    [FunctionName] NVARCHAR (50)  NOT NULL,
    [FunctionDesc] NVARCHAR (200) NULL,
    CONSTRAINT [PK_Function] PRIMARY KEY CLUSTERED ([FunctionId] ASC)
);

