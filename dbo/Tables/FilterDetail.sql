CREATE TABLE [dbo].[FilterDetail] (
    [FilterDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [FilterId]       INT            NOT NULL,
    [FieldId]        INT            NOT NULL,
    [Operator]       INT            NOT NULL,
    [Value]          VARCHAR (4000) NOT NULL,
    CONSTRAINT [PK_zFilterDetails] PRIMARY KEY CLUSTERED ([FilterDetailId] ASC)
);

