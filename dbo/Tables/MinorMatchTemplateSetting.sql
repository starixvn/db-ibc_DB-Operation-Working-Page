CREATE TABLE [dbo].[MinorMatchTemplateSetting] (
    [MinorBettypeId] INT             NOT NULL,
    [League]         NVARCHAR (2000) NOT NULL,
    [Home]           NVARCHAR (200)  NOT NULL,
    [Away]           NVARCHAR (200)  NULL,
    [IsRepresented]  BIT             NOT NULL,
    [IsActive]       BIT             NOT NULL
);




GO
CREATE CLUSTERED INDEX [CIX_MinorMatchTemplateSetting]
    ON [dbo].[MinorMatchTemplateSetting]([MinorBettypeId] DESC);

