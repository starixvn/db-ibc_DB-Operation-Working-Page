USE [bodb_OWP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

TRUNCATE TABLE [dbo].[MessageTemplate]

SET IDENTITY_INSERT [dbo].[MessageTemplate] ON
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (2, N'AssignmentDelete', N'AssignmentDelete', N'Your assignment has been REMOVED from <event>', 1, CAST(0x0000A6AC00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (1, N'AssignmentInsert', N'AssignmentInsert', N'You have been ASSIGNED to <event>', 1, CAST(0x0000A6AC00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (14, N'ChangeOfAssignment', N'ChangeOfAssignment', N'<user> edited an assignment of <event>
- Old: <oldAssignee>
- New: <newAssignee>', 1, CAST(0x0000A97A00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (30, N'EditAgent', N'EditAgent', N'<user> edited Agent of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00533B2F AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (19, N'EditChannel', N'EditChannel', N'<user> edited IPTV/Channel of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B004B7B81 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (27, N'EditDivision', N'EditDivision', N'<user> edited Division of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00530ADD AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (29, N'EditMarket', N'EditMarket', N'<user> edited Market of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00532ACD AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (25, N'EditMatchOffer', N'EditMatchOffer', N'<user> edited Match Offer of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B0052EAC6 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (35, N'EditNoOfHDP', N'EditNoOfHDP', N'<user> edited No of HDP of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97C0177D4E8 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (22, N'EditOtherProvider', N'EditOtherProvider', N'<user> edited Other Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00529298 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (23, N'EditOtherTime', N'EditOtherTime', N'<user> edited Other Time of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B0052B3BA AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (18, N'EditPhone', N'EditPhone', N'<user> edited Phone of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B0039FA1F AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (21, N'EditProvider', N'EditProvider', N'<user> edited Provider of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00526CF5 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (31, N'EditRemark', N'EditRemark', N'<user> edited Remark of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B0053559F AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (26, N'EditRound', N'EditRound', N'<user> edited Round of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B0052FCC8 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (11, N'EditTV', N'EditTV', N'<user> edited TV of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A9770005CA48 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (28, N'EditVenue', N'EditVenue', N'<user> edited Venue of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00531966 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (20, N'EditWB', N'EditWB', N'<user> edited WB of <home> vs <away><bettype>.
- Old: <oldvalue>
- New: <newvalue>', 1, CAST(0x0000A97B00522445 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (5, N'MatchNoteDelete', N'MatchNoteDelete', N'<user> deleted a note in <home> vs <away>.
Note content: <oldnote>', 1, CAST(0x0000A6CF00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (3, N'MatchNoteInsert', N'MatchNoteInsert', N'<user> added a note in <home> vs <away>.
Note content: <newnote>', 1, CAST(0x0000A6CF00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (4, N'MatchNoteUpdate', N'MatchNoteUpdate', N'<user> edited a note in <home> vs <away>.
- Old: <oldnote>
- New: <newnote>', 1, CAST(0x0000A6CF00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (17, N'MatchRecommendOddsInsert', N'MatchRecommendOddsInsert', N'<user> edited odds of <bettype> of <home> vs <away>. 
- Old: <oldodds> 
- New: <newodds>', 1, CAST(0x0000A97B00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (15, N'MatchRecommendOddsUpdate', N'MatchRecommendOddsUpdate', N'<user> edited odds of <bettype> of <home> vs <away>. 
- Old: <oldodds> 
- New: <newodds>', 1, CAST(0x0000A97B00000000 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (6, N'MatchStatus', N'MatchStatus', N'The match <event> has been <status>', 1, CAST(0x0000A7BC00522A95 AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (7, N'MinorMatchStatus', N'MinorMatchStatus', N'The match <event> - bettype: <bettype> has been <status>', 1, CAST(0x0000A92A0040DD1F AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (9, N'OtherAssignmentDelete', N'OtherAssignmentDelete', N'Your assignment has been REMOVED from <event> - note: <note>', 1, CAST(0x0000A92D015E88BD AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (8, N'OtherAssignmentInsert', N'OtherAssignmentInsert', N'You have been ASSIGNED to <event> - note: <note>', 1, CAST(0x0000A92D015E33ED AS DateTime), 1, 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateDesc], [MsgTemplateContent], [CreatedBy], [CreatedDate], [IsActive], [SystemMessageType]) VALUES (10, N'OtherAssignmentUpdate', N'OtherAssignmentUpdate', N'Your assignment has been EDITED in <event>
- Old note: <oldnote>
- New note: <newnote>', 1, CAST(0x0000A954006399F5 AS DateTime), 1, 1)
SET IDENTITY_INSERT [dbo].[MessageTemplate] OFF