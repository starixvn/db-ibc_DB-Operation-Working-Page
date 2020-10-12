/*
	Created: Leo.Vo
	Date: 20190704
	Task: [Redmine: #115459]
	DB: bodb_OWP
*/
USE bodb_OWP

TRUNCATE TABLE dbo.NotificationSetting
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (1, N'My assignment is updated
有關我的訊息', 0, N'True', 1)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (2, N'Trader assignment of my assigned match is updated
接收有關本賽事的操盤手更新訊息', 0, N'True', 2)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (3, N'The "Note" of my assigned match is updated
接收有關本賽事的現場注意訊息', 0, N'True', 4)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (4, N'The "Odds compiler" of my assigned match is updated
接收有關本賽事的現場行情更新訊息', 0, N'True', 5)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (5, N'The match info (Event, Round, Division, Remark, TV, Maxbet, Spread, Match Status...) of my assigned match is updated
接收有關本賽事的現場資訊更新訊息', 0, N'True', 6)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (6, N'Allow receive trader assignment of a match is updated
接收有關操盤手更新的訊息', 1, N'False', 1)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (7, N'Allow receive the "Note" of a match is updated
接收有關現場注意的訊息', 1, N'False', 3)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (8, N'Allow receive the "Odds compiler" of a match is updated
接收有關現場行情更新的訊息(Odds compiler)', 1, N'False', 4)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (9, N'Allow receive the match info (Event, Round, Division, Remark, TV, Maxbet, Spread, Match Status...) of a match is updated
接收有關現場資訊更新的訊息', 1, N'False', 5)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (10, N'LA assignment of my assigned match is updated
接收有關本賽事的現場助理更新訊息', 0, N'True', 3)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (11, N'The provider info of my assigned match is updated
接收有關本賽事的現場Provider更新訊息', 0, N'True', 7)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (12, N'Allow receive LA assignment of a match is updated
接收有關助理現場更新的訊息', 1, N'False', 2)
INSERT [dbo].[NotificationSetting] ([NotificationSettingId], [Name], [IsWatcher], [DefaultValue], [Order]) VALUES (13, N'Allow receive the "Provider" info of a match is updated
接收有關現場Provider更新的訊息', 1, N'False', 6)
GO

TRUNCATE TABLE dbo.MessageTemplate
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (2, N'AssignmentDelete', N'Your assignment has been REMOVED <Bettype> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (1, N'AssignmentInsert', N'You have been new ASSIGNED <Bettype> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (12, N'ChangeOfAssignment', N'Was updated <Bettype> from [ <Old> ] change to [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (25, N'EditAgent', N'Was updated Agent: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (15, N'EditChannel', N'Was updated IPTV/channel: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (22, N'EditDivision', N'Was updated Division: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (28, N'EditKOTime', N'Was updated KO Time: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (31, N'EditLeague', N'Was updated League name for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (24, N'EditMarket', N'Was updated Market: [ <New> ]  for the match: <Match.No> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (20, N'EditMatchOffer', N'Was updated Offer: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (13, N'EditMatchRecommendOdds', N'Was updated odds of <Bettype> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (29, N'EditMaxbet', N'Was updated Maxbet of <Bettype>: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (27, N'EditNoOfHDP', N'Was updated No of HDP: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (17, N'EditOtherProvider', N'Was updated Other Provider: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (19, N'EditOtherTime', N'Was updated Other Time: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (14, N'EditPhone', N'Was updated Phone: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (18, N'EditProvider', N'Was updated Provider: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (26, N'EditRemark', N'Was updated Remark: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (21, N'EditRound', N'Was updated Round: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (30, N'EditSpread', N'Was updated Spread of <Bettype>: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (32, N'EditTeam', N'Was updated Team name for the match: <Match.No> - <League> - <Event> updated by InfoSite, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (11, N'EditTV', N'Was updated TV: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (23, N'EditVenue', N'Was updated Venue: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (16, N'EditWB', N'Was updated WB: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (5, N'MatchNoteDelete', N'Was deleted a Note for the match: <Match.No> - <League> - <Event> updated by <User>, previous content: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (3, N'MatchNoteInsert', N'Please take note !, [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (4, N'MatchNoteUpdate', N'Was updated Note: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (6, N'MatchStatus', N'Has been <Status> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (7, N'MinorMatchStatus', N'Has been <Status> bettype: <Bettype> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (9, N'OtherAssignmentDelete', N'Your assignment has been REMOVED <Bettype> <Note> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (8, N'OtherAssignmentInsert', N'You have been new ASSIGNED <Bettype> <Note> for the match: <Match.No> - <League> - <Event> updated by <User>', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (10, N'OtherAssignmentUpdate', N'Was updated <Bettype> Other Assign: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
GO