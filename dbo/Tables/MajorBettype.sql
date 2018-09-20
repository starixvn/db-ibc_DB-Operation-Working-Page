CREATE TABLE [dbo].[MajorBettype] (
    [BettypeId] INT            NOT NULL,
    [Name]      NVARCHAR (128) NOT NULL,
    [ShortName] NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_MajorBettype] PRIMARY KEY CLUSTERED ([BettypeId] ASC) ON [PRIMARY]
);

