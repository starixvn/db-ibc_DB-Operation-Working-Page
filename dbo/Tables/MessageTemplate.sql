CREATE TABLE [dbo].[MessageTemplate] (
    [MsgTemplateId]      INT             IDENTITY (1, 1) NOT NULL,
    [MsgTemplateCode]    NVARCHAR (50)   NOT NULL,
    [MsgTemplateDesc]    NVARCHAR (200)  NOT NULL,
    [MsgTemplateContent] NVARCHAR (1000) NOT NULL,
    [CreatedBy]          INT             NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [IsActive]           BIT             CONSTRAINT [DF_MessageTemplate_IsActive] DEFAULT ((1)) NOT NULL,
    [LastModifiedBy]     INT             NULL,
    [LastModifiedDate]   DATETIME        NULL,
    [ParentMsgTypeId]    TINYINT         NULL,
    CONSTRAINT [PK_MessageTemplate] PRIMARY KEY CLUSTERED ([MsgTemplateId] ASC, [MsgTemplateCode] ASC)
);

