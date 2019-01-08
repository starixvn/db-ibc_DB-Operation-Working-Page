-- create table NotificationQueue
CREATE TABLE [dbo].[NotificationQueue](
	[Sessionid] [varchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_NotificationQueue] PRIMARY KEY CLUSTERED 
(
	[Sessionid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [OWP_Data]
) ON [OWP_Data]

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
