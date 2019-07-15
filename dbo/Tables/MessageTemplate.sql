CREATE TABLE [dbo].[MessageTemplate] (
    [MsgTemplateId]      INT             NOT NULL,
    [MsgTemplateCode]    NVARCHAR (50)   NOT NULL,
    [MsgTemplateContent] NVARCHAR (1000) NOT NULL,
    [SystemMessageType]  TINYINT         NOT NULL,
    CONSTRAINT [PK_MessageTemplate] PRIMARY KEY NONCLUSTERED ([MsgTemplateId] ASC) ON [OWP_Index]
);










GO
CREATE CLUSTERED INDEX [CIX_MessageTemplate]
    ON [dbo].[MessageTemplate]([MsgTemplateCode] ASC);

