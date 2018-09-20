CREATE TABLE [dbo].[FilterField] (
    [FieldId]    SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (100)  NOT NULL,
    [Text]       NVARCHAR (100) NULL,
    [IsRequired] BIT            NULL,
    CONSTRAINT [PK_FilterField] PRIMARY KEY CLUSTERED ([FieldId] ASC)
);

