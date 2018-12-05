/*
	Created: Raymond.Le
	Date: 2018-10-22
	Task: New structure table MessageTemplate, NotificationSetting
	DB: bodb_OWP
*/
USE [bodb_OWP]
GO

-- MessageTemplate 
EXECUTE	sys.sp_rename 'dbo.MessageTemplate', 'MessageTemplate_Old1';
EXECUTE	sys.sp_rename 'PK_MessageTemplate', 'PK_MessageTemplate_Old1';
EXECUTE	sys.sp_rename 'DF_MessageTemplate_IsActive', 'DF_MessageTemplate_IsActive_Old1';
EXECUTE	sys.sp_rename 'DF_MessageTemplate_CreatedDate', 'DF_MessageTemplate_CreatedDate_Old1';

CREATE TABLE dbo.MessageTemplate (
					MsgTemplateId			INT				NOT NULL
				,	MsgTemplateCode			NVARCHAR(50)	NOT NULL
				,	MsgTemplateContent		NVARCHAR(1000)	NOT NULL
				,	IsActive				BIT				NOT NULL	CONSTRAINT DF_MessageTemplate_IsActive DEFAULT ((1))
				,	SystemMessageType		TINYINT			NOT NULL
				,	CONSTRAINT	PK_MessageTemplate PRIMARY KEY NONCLUSTERED (MsgTemplateId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MessageTemplate ON dbo.MessageTemplate (
							MsgTemplateCode	ASC
						) ON OWP_Data;

DROP TABLE dbo.MessageTemplate_Old1
DROP TABLE dbo.MessageTemplate_Old

-- NotificationSetting
EXECUTE	sys.sp_rename 'dbo.NotificationSetting', 'NotificationSetting_Old';
EXECUTE	sys.sp_rename 'PK_NotificationSetting', 'PK_NotificationSetting_Old';
EXECUTE	sys.sp_rename 'DF_NotificationSetting_IsWatcher', 'DF_NotificationSetting_IsWatcher_Old';

CREATE TABLE	dbo.NotificationSetting (
					NotificationSettingId	SMALLINT		NOT NULL
				,	[Name]					NVARCHAR(250)	NOT NULL
				,	IsWatcher				BIT				NOT NULL	CONSTRAINT DF_NotificationSetting_IsWatcher DEFAULT ((0))
				,	DefaultValue			NVARCHAR(250)	NULL
				,	CONSTRAINT	PK_NotificationSetting PRIMARY KEY CLUSTERED (NotificationSettingId ASC) ON OWP_Data
				) ON OWP_Data;

DROP TABLE dbo.NotificationSetting_Old

-- Create type
CREATE TYPE [dbo].[TVP_INT] AS TABLE(
	[Id] [int] NULL
)
GO

