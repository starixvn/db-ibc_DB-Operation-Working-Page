CREATE TABLE [dbo].[RefResource] (
    [RefName]    VARCHAR (30)   NOT NULL,
    [ResourceId] INT            NOT NULL,
    [Value]      NVARCHAR (200) NOT NULL,
    [Order]      SMALLINT       CONSTRAINT [DF_RefResource_Order] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RefResource] PRIMARY KEY CLUSTERED ([RefName] ASC, [ResourceId] ASC)
);








GO


