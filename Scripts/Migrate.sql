USE [bodb_OWP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

TRUNCATE TABLE [dbo].[MessageTemplate]

SET IDENTITY_INSERT [dbo].[MessageTemplate] ON 
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (2, N'AssignmentDelete', N'AssignmentDelete', N'Your assignment has been REMOVED from <event>', 1, CAST(N'2016-10-27T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (1, N'AssignmentInsert', N'AssignmentInsert', N'You have been ASSIGNED to <event>', 1, CAST(N'2016-10-27T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (14, N'ChangeOfAssignment', N'ChangeOfAssignment', N'<user> edited an assignment of <event>
- Old: <oldAssignee>
- New: <newAssignee>', 1, CAST(N'2018-10-15T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (30, N'EditAgent', N'EditAgent', N'<user> edited Agent of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:03:02.130' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (19, N'EditChannel', N'EditChannel', N'<user> edited IPTV/Channel of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T04:34:49.390' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (27, N'EditDivision', N'EditDivision', N'<user> edited Division of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:02:20.897' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (29, N'EditMarket', N'EditMarket', N'<user> edited Market of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:02:48.150' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (25, N'EditMatchOffer', N'EditMatchOffer', N'<user> edited Match Offer of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:01:53.513' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (17, N'EditMatchRecommendOdds', N'EditMatchRecommendOdds', N'<user> edited odds of <bettype> of <home> vs <away>. 
- Old: <oldodds> 
- New: <newodds>', 1, CAST(N'2018-10-16T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (35, N'EditNoOfHDP', N'EditNoOfHDP', N'<user> edited No of HDP of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-17T22:48:21.680' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (22, N'EditOtherProvider', N'EditOtherProvider', N'<user> edited Other Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:00:38.267' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (23, N'EditOtherTime', N'EditOtherTime', N'<user> edited Other Time of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:01:06.540' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (18, N'EditPhone', N'EditPhone', N'<user> edited Phone of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T03:31:05.277' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (21, N'EditProvider', N'EditProvider', N'<user> edited Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:00:06.150' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (31, N'EditRemark', N'EditRemark', N'<user> edited Remark of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:03:24.690' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (26, N'EditRound', N'EditRound', N'<user> edited Round of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:02:08.880' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (11, N'EditTV', N'EditTV', N'<user> edited TV of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-12T00:21:04.880' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (28, N'EditVenue', N'EditVenue', N'<user> edited Venue of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T05:02:33.300' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (20, N'EditWB', N'EditWB', N'<user> edited WB of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(N'2018-10-16T04:59:04.123' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (5, N'MatchNoteDelete', N'MatchNoteDelete', N'<user> deleted a note in <home> vs <away>.
Note content: <oldnote>', 1, CAST(N'2016-12-01T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (3, N'MatchNoteInsert', N'MatchNoteInsert', N'<user> added a note in <home> vs <away>.
Note content: <newnote>', 1, CAST(N'2016-12-01T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (4, N'MatchNoteUpdate', N'MatchNoteUpdate', N'<user> edited a note in <home> vs <away>.
- Old: <oldnote>
- New: <newnote>', 1, CAST(N'2016-12-01T00:00:00.000' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (6, N'MatchStatus', N'MatchStatus', N'The match <event> has been <status>', 1, CAST(N'2017-07-26T04:59:09.510' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (7, N'MinorMatchStatus', N'MinorMatchStatus', N'The match <event> - bettype: <bettype> has been <status>', 1, CAST(N'2018-07-27T03:56:09.703' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (9, N'OtherAssignmentDelete', N'OtherAssignmentDelete', N'Your assignment has been REMOVED from <event> - note: <note>', 1, CAST(N'2018-07-30T21:16:15.350' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (8, N'OtherAssignmentInsert', N'OtherAssignmentInsert', N'You have been ASSIGNED to <event> - note: <note>', 1, CAST(N'2018-07-30T21:15:02.977' AS DateTime), 1, 1)
GO
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (10, N'OtherAssignmentUpdate', N'OtherAssignmentUpdate', N'Your assignment has been EDITED in <event>
- Old note: <oldnote>
- New note: <newnote>', 1, CAST(N'2018-09-07T06:02:38.257' AS DateTime), 1, 1)
GO
SET IDENTITY_INSERT [dbo].[MessageTemplate] OFF