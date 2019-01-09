-- create table NotificationQueue
CREATE TABLE [dbo].[NotificationQueue] (
    [Sessionid]   VARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_NotificationQueue_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_NotificationQueue] PRIMARY KEY CLUSTERED ([Sessionid] ASC)
);

-- insert message template
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (28, N'EditKOTime', N'<user> edited KO Time of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (29, N'EditMaxbet', N'<user> edited Maxbet <type> of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (30, N'EditSpread', N'<user> edited Spread <type> of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (31, N'EditLeague', N'InfoSite edited League of <home> vs <away>.
- Old: <oldvalue>
- New: <newvalue>', 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [IsActive], [SystemMessageType]) VALUES (32, N'EditTeam', N'InfoSite edited Team of match from <oldevent> to <newevent>', 1, 1)
