/*
	Created: Leo.Vo
	Date: 20190715
	Task: [Redmine: #116688]
	DB: bodb_OWP
*/
USE bodb_OWP

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBetHDP_CN88]     NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBetHDP_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [SpreadHDP_CN88]     NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_SpreadHDP_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBet1HHDP_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBet1HHDP_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [Spread1HHDP_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_Spread1HHDP_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBetOU_CN88]      NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBetOU_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [SpreadOU_CN88]      NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_SpreadOU_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBet1HOU_CN88]    NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBet1HOU_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [Spread1HOU_CN88]    NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_Spread1HOU_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBet1X2_CN88]     NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBet1X2_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [Spread1X2_CN88]     NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_Spread1X2_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBet1H1X2_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBet1H1X2_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [Spread1H1X2_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_Spread1H1X2_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBetXMins_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBetXMins_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [SpreadXMins_CN88]   NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_SpreadXMins_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [MaxBetFM_CN88]      NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_MaxBetFM_CN88] DEFAULT (N'') NOT NULL

ALTER TABLE dbo.AssignmentUploading
ADD [SpreadFM_CN88]      NVARCHAR (200)  CONSTRAINT [DF_AssignmentUploading_SpreadFM_CN88] DEFAULT (N'') NOT NULL

GO

ALTER TABLE dbo.MatchSetting
ADD [MaxbetCN88]      MONEY NULL

ALTER TABLE dbo.MatchSetting
ADD [SpreadCN88]      SMALLMONEY NULL

GO

INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (33, N'EditMaxbetCN88', N'Was updated Maxbet (CN88) of <Bettype>: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
INSERT [dbo].[MessageTemplate] ([MsgTemplateId], [MsgTemplateCode], [MsgTemplateContent], [SystemMessageType]) VALUES (34, N'EditSpreadCN88', N'Was updated Spread (CN88) of <Bettype>: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]', 1)
GO