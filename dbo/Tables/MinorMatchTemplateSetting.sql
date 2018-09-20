CREATE TABLE [dbo].[MinorMatchTemplateSetting] (
    [MinorBettypeId] INT             NOT NULL,
    [League]         NVARCHAR (2000) NOT NULL,
    [Home]           NVARCHAR (200)  NOT NULL,
    [Away]           NVARCHAR (200)  NULL,
    [IsRepresented]  BIT             NOT NULL,
    [IsActive]       BIT             NOT NULL
) ON [PRIMARY];

