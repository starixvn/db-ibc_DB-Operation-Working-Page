/*
	Creator:	20181009@Leo
	Task:		Schema migration for new OWP - [Redmine: #102733]
	Server:		DBOWP.bodb_OWP

	Review & Tested:	Billy
*/

-- Agent -- New --
CREATE TABLE	dbo.Agent (
					AgentId					INT				NOT NULL	IDENTITY(1, 1)
				,	AgentName				NVARCHAR(100)	NOT NULL
				,	CONSTRAINT	PK_Agent PRIMARY KEY CLUSTERED (AgentId ASC) ON OWP_Data
				) ON OWP_Data;

-- Provider -- New --
CREATE TABLE	dbo.Provider (
					ProviderId				INT				NOT NULL	IDENTITY(1, 1)
				,	ProviderName			NVARCHAR(100)	NOT NULL
				,	CONSTRAINT	PK_Provider PRIMARY KEY CLUSTERED (ProviderId ASC) ON OWP_Data
				) ON OWP_Data;

-- Runner -- New --
CREATE TABLE	dbo.Runner (
					RunnerId				INT				NOT NULL	IDENTITY(1, 1)
				,	RunnerName				NVARCHAR(100)	NOT NULL
				,	CONSTRAINT	PK_Runner PRIMARY KEY CLUSTERED (RunnerId ASC) ON OWP_Data
				) ON OWP_Data;

-- RefResource -- Migrated --
EXECUTE	sys.sp_rename 'dbo.RefResource', 'RefResource_Old';
EXECUTE	sys.sp_rename 'PK_RefResource', 'PK_RefResource_Old';

CREATE TABLE	dbo.RefResource (
					RefResourceId			INT				NOT NULL
				,	RefName					VARCHAR(30)		NOT NULL
				,	ResourceId				INT				NOT NULL
				,	Value					NVARCHAR(200)	NOT NULL
				,	CONSTRAINT	PK_RefResource PRIMARY KEY CLUSTERED (RefName ASC, ResourceId ASC) ON OWP_Data
				) ON OWP_Data;

-- Television -- Migrated --
EXECUTE	sys.sp_rename 'dbo.Television', 'Television_Old';
EXECUTE	sys.sp_rename 'PK_Television', 'PK_Television_Old';

CREATE TABLE	dbo.Television (
					TVId					INT				NOT NULL	IDENTITY(1, 1)
				,	TVCode					NVARCHAR(100)	NOT NULL
				,	Color					VARCHAR(20)		NOT NULL	CONSTRAINT DF_Television_Color DEFAULT ('#444')
				,	CONSTRAINT	PK_Television PRIMARY KEY CLUSTERED (TVId ASC) ON OWP_Data
				) ON OWP_Data;

-- EmployeeWorkingShift -- Add Columns --
ALTER TABLE dbo.EmployeeWorkingShift ADD ShiftStartTime DATETIME NULL;
ALTER TABLE dbo.EmployeeWorkingShift ADD ShiftEndTime DATETIME NULL;

-- AssignmentUploading -- Migrated --
EXECUTE	sys.sp_rename 'dbo.AssignmentUploading', 'AssignmentUploading_Old';
EXECUTE	sys.sp_rename 'PK_AssignmentUploading', 'PK_AssignmentUploading_Old';

CREATE TABLE	dbo.AssignmentUploading (
					SessionId				VARCHAR(50)		NOT NULL
				,	RowNumber				INT				NOT NULL
				,	EventDate				DATE			NOT NULL
				,	MatchNo					VARCHAR(50)		NOT NULL	CONSTRAINT DF_AssignmentUploading_MatchNo DEFAULT ('')
				,	MatchStatus				VARCHAR(15)		NOT NULL	CONSTRAINT DF_AssignmentUploading_MatchStatus DEFAULT ('Live')
				,	MatchId					NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MatchId DEFAULT (N'')
				,	KickOffTime				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_KickOffTime DEFAULT (N'')
				,	OtherTime				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_OtherTime DEFAULT (N'')
				,	MatchOffer				NVARCHAR(50)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MatchOffer DEFAULT (N'')
				,	League					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_League DEFAULT (N'')
				,	Home					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Home DEFAULT (N'')
				,	Away					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Away DEFAULT (N'')
				,	Note					XML				NULL
				,	Round					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Round DEFAULT (N'')
				,	Division				NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Division DEFAULT (N'')
				,	Remark					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Remark DEFAULT (N'')
				,	MaxBetHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBetHDP DEFAULT (N'')
				,	SpreadHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_SpreadHDP DEFAULT (N'')
				,	NoHDP					NVARCHAR(20)	NOT NULL	CONSTRAINT DF_AssignmentUploading_NoHDP DEFAULT (N'')
				,	TraderHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_TraderHDP DEFAULT (N'')
				,	OtherTradersHDP			XML				NULL
				,	MaxBet1HHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBet1HHDP DEFAULT (N'')
				,	Spread1HHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Spread1HHDP DEFAULT (N'')
				,	Trader1HHDP				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader1HHDP DEFAULT (N'')
				,	OtherTraders1HHDP		XML				NULL
				,	MaxBetOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBetOU DEFAULT (N'')
				,	SpreadOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_SpreadOU DEFAULT (N'')
				,	TraderOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_TraderOU DEFAULT (N'')
				,	OtherTradersOU			XML				NULL
				,	MaxBet1HOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBet1HOU DEFAULT (N'')
				,	Spread1HOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Spread1HOU DEFAULT (N'')
				,	Trader1HOU				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader1HOU DEFAULT (N'')
				,	OtherTraders1HOU		XML				NULL
				,	MaxBet1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBet1X2 DEFAULT (N'')
				,	Spread1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Spread1X2 DEFAULT (N'')
				,	Trader1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader1X2 DEFAULT (N'')
				,	OtherTraders1X2			XML				NULL
				,	MaxBet1H1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBet1H1X2 DEFAULT (N'')
				,	Spread1H1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Spread1H1X2 DEFAULT (N'')
				,	Trader1H1X2				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader1H1X2 DEFAULT (N'')
				,	OtherTraders1H1X2		XML				NULL
				,	MaxBetXMins				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBetXMins DEFAULT (N'')
				,	SpreadXMins				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_SpreadXMins DEFAULT (N'')
				,	Trader15Mins			NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader15Mins DEFAULT (N'')
				,	OtherTraders15Mins		XML				NULL
				,	Trader10Mins			NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Trader10Mins DEFAULT (N'')
				,	OtherTraders10Mins		XML				NULL
				,	LA						NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_LA DEFAULT (N'')
				,	OtherLA					XML				NULL
				,	MaxBetFM				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_MaxBetFM DEFAULT (N'')
				,	SpreadFM				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_SpreadFM DEFAULT (N'')
				,	TraderFM				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_TraderFM DEFAULT (N'')
				,	OtherTradersFM			XML				NULL
				,	TraderAIO				NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploading_TraderAIO DEFAULT (N'')
				,	OtherTradersAIO			XML				NULL
				,	Agent					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Agent DEFAULT (N'')
				,	TV						NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_TV DEFAULT (N'')
				,	Channel					NVARCHAR(100)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Channel DEFAULT (N'')
				,	WB						NVARCHAR(100)	NOT NULL	CONSTRAINT DF_AssignmentUploading_WB DEFAULT (N'')
				,	Provider				NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Provider DEFAULT (N'')
				,	Runner					NVARCHAR(2000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Runner DEFAULT (N'')
				,	Phone					NVARCHAR(50)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Phone DEFAULT (N'')
				,	Website1				NVARCHAR(1000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Website1 DEFAULT (N'')
				,	Website2				NVARCHAR(1000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Website2 DEFAULT (N'')
				,	Website3				NVARCHAR(1000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Website3 DEFAULT (N'')
				,	Website4				NVARCHAR(1000)	NOT NULL	CONSTRAINT DF_AssignmentUploading_Website4 DEFAULT (N'')
				,	MinorBettypeId			INT				NULL
				,	ParentRowNumber			INT				NULL
				,	CONSTRAINT	PK_AssignmentUploading PRIMARY KEY CLUSTERED (SessionId ASC, RowNumber ASC) ON OWP_Data
				) ON OWP_Data;

-- AssignmentUploadingLog -- Migrated --
EXECUTE	sys.sp_rename 'dbo.AssignmentUploadingLog', 'AssignmentUploadingLog_Old';
EXECUTE	sys.sp_rename 'PK_AssignmentUploadingLog', 'PK_AssignmentUploadingLog_Old';

CREATE TABLE	dbo.AssignmentUploadingLog (
					SessionId				VARCHAR(50)		NOT NULL
				,	UserId					INT				NOT NULL
				,	TotalRowResult			INT				NOT NULL
				,	CreatedDate				DATETIME		NOT NULL	CONSTRAINT DF_AssignmentUploadingLog_CreatedDate DEFAULT (GETDATE())
				,	StartDate				DATETIME		NULL
				,	EndDate					DATETIME		NULL
				,	Status					TINYINT			NOT NULL
				,	LogMessage				VARCHAR(MAX)	NOT NULL	CONSTRAINT DF_AssignmentUploadingLog_LogMessage DEFAULT ('')
				,	CONSTRAINT	PK_AssignmentUploadingLog PRIMARY KEY CLUSTERED (SessionId ASC) ON OWP_DATA
				) ON OWP_DATA;

CREATE NONCLUSTERED INDEX	IX_AssginmentUploadingLog ON dbo.AssignmentUploadingLog (
								CreatedDate	ASC
							) ON OWP_Index;

-- AssignmentUploadingResult -- Migrated --
EXECUTE	sys.sp_rename 'dbo.AssignmentUploadingResult', 'AssignmentUploadingResult_Old';
EXECUTE	sys.sp_rename 'PK_AssignmentUploadingResult', 'PK_AssignmentUploadingResult_Old';

CREATE TABLE	dbo.AssignmentUploadingResult (
					SessionId				VARCHAR(50)		NOT NULL
				,	RowNumber				INT				NOT NULL
				,	RuleId					SMALLINT		NOT NULL
				,	ResultType				SMALLINT		NOT NULL
				,	Message					NVARCHAR(MAX)	NULL
				,	CONSTRAINT	PK_AssignmentUploadingResult PRIMARY KEY CLUSTERED (SessionId ASC, RowNumber ASC, RuleId ASC) ON OWP_Data
				) ON OWP_Data;

-- AssignmentUploadingOtherTrader -- New --
CREATE TABLE	dbo.AssignmentUploadingOtherTrader (
					AssignmentId			INT				NOT NULL	IDENTITY(1, 1)
				,	SessionId				VARCHAR(50)		NOT NULL
				,	RowNumber				INT				NOT NULL
				,	Bettype					INT				NOT NULL
				,	Trader					NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploadingOtherTrader_Trader DEFAULT ('')
				,	Note					NVARCHAR(200)	NOT NULL	CONSTRAINT DF_AssignmentUploadingOtherTrader_Note DEFAULT ('')
				,	CONSTRAINT	PK_AssignmentUploadingOtherTrader PRIMARY KEY NONCLUSTERED (AssignmentId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_AssignmentUploadingOtherTrader ON dbo.AssignmentUploadingOtherTrader (
							SessionId	ASC
						,	RowNumber	ASC
						,	Trader		ASC
						) ON OWP_Data;

-- Function -- Migrated --
EXECUTE	sys.sp_rename 'dbo.Function', 'Function_Old';
EXECUTE	sys.sp_rename 'PK_Function', 'PK_Function_Old';

CREATE TABLE	dbo.[Function] (
					FunctionId				SMALLINT		NOT NULL	IDENTITY(1, 1)
				,	FunctionName			NVARCHAR(50)	NOT NULL
				,	FunctionDesc			NVARCHAR(200)	NULL
				,	CONSTRAINT	PK_Function PRIMARY KEY CLUSTERED (FunctionId ASC) ON OWP_Data
				) ON OWP_Data;

-- FunctionRule -- Migrated --
EXECUTE	sys.sp_rename 'dbo.FunctionRule', 'FunctionRule_Old';
EXECUTE	sys.sp_rename 'PK_FunctionRule', 'PK_FunctionRule_Old';

CREATE TABLE	dbo.FunctionRule (
					FunctionId				SMALLINT		NOT NULL
				,	RuleId					SMALLINT		NOT NULL
				,	[Order]					SMALLINT		NULL
				,	CONSTRAINT	PK_FunctionRule PRIMARY KEY CLUSTERED (FunctionId ASC, RuleId ASC) ON OWP_Data
				) ON OWP_Data;

-- MajorBettype - Migrated --
EXECUTE	sys.sp_rename 'dbo.MajorBettype', 'MajorBettype_Old';
EXECUTE	sys.sp_rename 'PK_MajorBettype', 'PK_MajorBettype_Old';

CREATE TABLE	dbo.MajorBettype (
					BettypeId				INT				NOT NULL
				,	Name					NVARCHAR(128)	NOT NULL
				,	ShortName				NVARCHAR(128)	NOT NULL
				,	CONSTRAINT	PK_MajorBettype PRIMARY KEY CLUSTERED (BettypeId ASC) ON OWP_Data
				) ON OWP_Data;

-- Assignment -- Migrated --
EXECUTE	sys.sp_rename 'dbo.Assignment', 'Assignment_Old';

CREATE TABLE	dbo.Assignment (
					AssignmentId			INT				NOT NULL	IDENTITY(1, 1)
				,	OWPMatchId				INT				NOT NULL
				,	Bettype					INT				NOT NULL
				,	AssignmentType			TINYINT			NOT NULL
				,	UserId					INT				NULL
				,	AssignmentNote			NVARCHAR(200)	NULL
				,	CONSTRAINT	PK_Assignment PRIMARY KEY NONCLUSTERED (AssignmentId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_Assignment ON dbo.Assignment (
							OWPMatchId		ASC
						,	Bettype			ASC
						,	AssignmentType	ASC
						) ON OWP_Data;

-- MatchInfo -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MatchInfo', 'MatchInfo_Old';
EXECUTE	sys.sp_rename 'PK_MatchInfo', 'PK_MatchInfo_Old';

CREATE TABLE	dbo.MatchInfo (
					OWPMatchId				INT				NOT NULL
				,	NoOfHDP					NVARCHAR(20)	NULL
				,	Channel					NVARCHAR(100)	NULL
				,	WB						NVARCHAR(100)	NULL
				,	Provider				NVARCHAR(100)	NULL
				,	Runner					NVARCHAR(100)	NULL
				,	Phone					NVARCHAR(50)	NULL
				,	KOTimeRemark			NVARCHAR(50)	NULL
				,	ExtraTimeRemark			NVARCHAR(100)	NULL
				,	Venue					NVARCHAR(100)	NULL
				,	TVCode					NVARCHAR(500)	NULL
				,	LocalTV					NVARCHAR(100)	NULL
				,	LiveTV					NVARCHAR(100)	NULL
				,	Agent					NVARCHAR(100)	NULL
				,	IsSelectedUpdatedDate	DATETIME		NULL
				,	IsSelected				BIT				NOT NULL	CONSTRAINT DF_MatchInfo_IsSelected DEFAULT ((0))
				,	SelectedBy				INT				NULL
				,	IsSoloMatch				BIT				NOT NULL	CONSTRAINT DF_MatchInfo_IsSoloMatch DEFAULT ((0))
				,	Round					NVARCHAR(2000)	NULL
				,	Division				NVARCHAR(2000)	NULL
				,	Remark					NVARCHAR(2000)	NULL
				,	Website1				NVARCHAR(1000)	NULL
				,	Website2				NVARCHAR(1000)	NULL
				,	Website3				NVARCHAR(1000)	NULL
				,	Website4				NVARCHAR(1000)	NULL
				,	MatchStatus				VARCHAR(15)		NOT NULL	CONSTRAINT DF_MatchInfo_MatchStatus DEFAULT ('Live')
				,	CONSTRAINT	PK_MatchInfo PRIMARY KEY CLUSTERED (OWPMatchId ASC) ON OWP_Data
				) ON OWP_Data;

-- MatchNote -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MatchNote', 'MatchNote_Old';
EXECUTE	sys.sp_rename 'PK_MatchNote', 'PK_MatchNote_Old';

CREATE TABLE	dbo.MatchNote (
					MatchNoteId				INT				NOT NULL	IDENTITY(1, 1)
				,	OWPMatchId				INT				NOT NULL
				,	CreatedDate				DATETIME		NOT NULL	CONSTRAINT DF_MatchNote_CreatedDate DEFAULT (GETDATE())
				,	CreatedBy				INT				NOT NULL
				,	Note					NVARCHAR(4000)	NOT NULL
				,	CONSTRAINT	PK_MatchNote PRIMARY KEY NONCLUSTERED (MatchNoteId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MatchNote ON dbo.MatchNote (
							OWPMatchId	ASC
						) ON OWP_Data;

-- MatchSetting -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MatchSetting', 'MatchSetting_Old';
EXECUTE	sys.sp_rename 'PK_MatchSetting', 'PK_MatchSetting_Old';

CREATE TABLE	dbo.MatchSetting (
					OWPMatchId				INT				NOT NULL
				,	Bettype					INT				NOT NULL
				,	Spread					SMALLMONEY		NULL
				,	Maxbet					MONEY			NULL
				,	CONSTRAINT	PK_MatchSetting PRIMARY KEY CLUSTERED (OWPMatchId ASC, Bettype ASC) ON OWP_Data
				) ON OWP_Data;

-- Message -- Migrated --
EXECUTE	sys.sp_rename 'dbo.Message', 'Message_Old';
EXECUTE	sys.sp_rename 'PK_Message', 'PK_Message_Old';
EXECUTE	sys.sp_rename 'DF_Message_IsImportant', 'DF_Message_IsImportant_Old';
EXECUTE	sys.sp_rename 'DF_Message_IsPermanent', 'DF_Message_IsPermanent_Old';

CREATE TABLE	dbo.Message (
					MessageId				INT				NOT NULL	IDENTITY(1, 1)
				,	MessageContent			NVARCHAR(MAX)	NOT NULL
				,	CreatedBy				INT				NOT NULL
				,	CreatedDate				DATETIME		NOT NULL	CONSTRAINT DF_Message_CreatedDate DEFAULT (GETDATE())
				,	IsImportant				BIT				NULL		CONSTRAINT DF_Message_IsImportant DEFAULT ((0))
				,	MessageType				TINYINT			NOT NULL
				,	CONSTRAINT	PK_Message PRIMARY KEY CLUSTERED (MessageId ASC) ON OWP_Data
				) ON OWP_Data TEXTIMAGE_ON OWP_Data;

-- MessageTemplate -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MessageTemplate', 'MessageTemplate_Old';
EXECUTE	sys.sp_rename 'PK_MessageTemplate', 'PK_MessageTemplate_Old';
EXECUTE	sys.sp_rename 'DF_MessageTemplate_IsActive', 'DF_MessageTemplate_IsActive_Old';

CREATE TABLE	dbo.MessageTemplate (
					MsgTemplateId			INT				NOT NULL	IDENTITY(1, 1)
				,	MsgTemplateCode			NVARCHAR(50)	NOT NULL
				,	MsgTemplateDesc			NVARCHAR(200)	NOT NULL
				,	MsgTemplateContent		NVARCHAR(1000)	NOT NULL
				,	CreatedBy				INT				NOT NULL
				,	CreatedDate				DATETIME		NOT NULL	CONSTRAINT DF_MessageTemplate_CreatedDate DEFAULT (GETDATE())
				,	IsActive				BIT				NOT NULL	CONSTRAINT DF_MessageTemplate_IsActive DEFAULT ((1))
				,	SystemMessageType		TINYINT			NOT NULL
				,	CONSTRAINT	PK_MessageTemplate PRIMARY KEY NONCLUSTERED (MsgTemplateId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MessageTemplate ON dbo.MessageTemplate (
							MsgTemplateCode	ASC
						) ON OWP_Data;

-- MessageUser -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MessageUser', 'MessageUser_Old';
EXECUTE	sys.sp_rename 'PK_MessageUser', 'PK_MessageUser_Old';
EXECUTE	sys.sp_rename 'DF_MessageUser_IsViewed', 'DF_MessageUser_IsViewed_Old';

CREATE TABLE	dbo.MessageUser (
					MessageUserId			INT				NOT NULL	IDENTITY(1, 1)
				,	MessageId				INT				NOT NULL
				,	UserId					INT				NOT NULL
				,	IsViewed				BIT				NOT NULL	CONSTRAINT DF_MessageUser_IsViewed DEFAULT ((0))
				,	CreatedDate				DATETIME		NULL		CONSTRAINT DF_MessageUser_CreatedDate DEFAULT (GETDATE())
				,	CreatedBy				INT				NULL
				,	SessionId				NVARCHAR(100)	NULL
				,	CONSTRAINT	PK_MessageUser PRIMARY KEY NONCLUSTERED (MessageUserId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MessageUser ON dbo.MessageUser (
							UserId	ASC
						) ON OWP_Data;

CREATE NONCLUSTERED INDEX	IX_MessageUser_MessageId ON dbo.MessageUser (
								MessageId	ASC
							) ON OWP_Index;

CREATE NONCLUSTERED INDEX	IX_MessageUser_SessionId ON dbo.MessageUser (
								SessionId	ASC
							) ON OWP_Index;

-- MinorBettype -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MinorBettype', 'MinorBettype_Old';

CREATE TABLE	dbo.MinorBettype (
					MinorBettypeId			INT				NOT NULL	IDENTITY(-1, -1)
				,	MinorBettypeName		NVARCHAR(100)	NOT NULL
				,	ParentBettypeId			INT				NULL
				,	InheritedBettypeId		INT				NULL
				,	Alias					VARCHAR(10)		NULL
				,	IsActive				BIT				NULL
				,	IsMinorBettype			BIT				NULL
				,	CONSTRAINT	PK_MinorBettype PRIMARY KEY CLUSTERED (MinorBettypeId DESC) ON OWP_Data
				) ON OWP_Data;

CREATE NONCLUSTERED INDEX	IX_MinorBettype_ParentInherited ON dbo.MinorBettype (
								ParentBettypeId		ASC
							,	InheritedBettypeId	ASC
							)
							INCLUDE (MinorBettypeName, IsActive) ON OWP_Index;

-- MinorMatch -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MinorMatch', 'MinorMatch_Old';

CREATE TABLE	dbo.MinorMatch (
					RelationshipId			INT				NOT NULL	IDENTITY(1, 1)
				,	MinorMatchId			INT				NOT NULL
				,	ParentMatchId			INT				NOT NULL
				,	MinorBettypeId			INT				NOT NULL
				,	IsRepresented			BIT				NOT NULL
				,	GroupId					INT				NULL
				,	CONSTRAINT	PK_MinorMatch PRIMARY KEY NONCLUSTERED (RelationshipId ASC) ON OWP_Data
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MinorMatch ON dbo.MinorMatch (
							MinorMatchId	ASC
						) ON OWP_Data;

-- MinorMatchDetemination -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MinorMatchDetemination', 'MinorMatchDetemination_Old';

CREATE TABLE	dbo.MinorMatchDetemination (
					MinorBettypeId			INT				NULL
				,	Field					SMALLINT		NULL
				,	Condition				SMALLINT		NULL
				,	Value					NVARCHAR(2000)	NULL
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MinorMatchDetemination ON dbo.MinorMatchDetemination (
							MinorBettypeId	DESC
						) ON OWP_Data;

-- MinorMatchTemplateSetting -- Migrated --
EXECUTE	sys.sp_rename 'dbo.MinorMatchTemplateSetting', 'MinorMatchTemplateSetting_Old';

CREATE TABLE	dbo.MinorMatchTemplateSetting (
					MinorBettypeId			INT				NOT NULL
				,	League					NVARCHAR(2000)	NOT NULL
				,	Home					NVARCHAR(200)	NOT NULL
				,	Away					NVARCHAR(200)	NULL
				,	IsRepresented			BIT				NOT NULL
				,	IsActive				BIT				NOT NULL
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MinorMatchTemplateSetting ON dbo.MinorMatchTemplateSetting (
							MinorBettypeId	DESC
						) ON OWP_Data;

-- OWPLeague -- Alter column --
-- 73 rows affected --
UPDATE	dbo.OWPLeague WITH (ROWLOCK, UPDLOCK)
SET IsActive = 0
WHERE IsActive IS NULL;

ALTER TABLE dbo.OWPLeague ALTER COLUMN isActive BIT NOT NULL;
ALTER TABLE dbo.OWPLeague ADD CONSTRAINT DF_OWPLeague_IsActive DEFAULT ((1)) FOR isActive;

-- OWPMatch -- Migrated --
EXECUTE	sys.sp_rename 'dbo.OWPMatch', 'OWPMatch_Old';
EXECUTE	sys.sp_rename 'PK_OWPMatch', 'PK_OWPMatch_Old';

CREATE TABLE	dbo.OWPMatch (
					OWPMatchId				INT				NOT NULL	IDENTITY(1, 1)
				,	MatchNo					VARCHAR(50)		NOT NULL	CONSTRAINT DF_OWPMatch_MatchNo DEFAULT ('')
				,	EventDate				DATETIME		NOT NULL
				,	KickOffTime				TIME(7)			NOT NULL
				,	OWPLeagueId				INT				NOT NULL
				,	OWPHomeId				INT				NOT NULL
				,	OWPAwayId				INT				NOT NULL
				,	MatchId					INT				NULL
				,	OtherTime				TIME(7)			NULL
				,	EventDateTime			DATETIME		NULL
				,	InfositeMatchKey		NVARCHAR(400)	NULL
				,	IsChecked				BIT				NULL
				,	CONSTRAINT	PK_OWPMatch PRIMARY KEY CLUSTERED (OWPMatchId ASC) ON OWP_Data
				) ON OWP_Data;

-- ValidationRule -- Migrated --
EXECUTE	sys.sp_rename 'dbo.ValidationRule', 'ValidationRule_Old';

CREATE TABLE	dbo.ValidationRule (
					RuleId					SMALLINT		NOT NULL	IDENTITY(1, 1)
				,	RuleName				NVARCHAR(50)	NOT NULL
				,	Description				NVARCHAR(200)	NULL
				,	IsActive				BIT				NOT NULL	CONSTRAINT DF_ValidationRule_IsActive DEFAULT ((1))
				,	RuleResultType			SMALLINT		NOT NULL
				,	Category				SMALLINT		NOT NULL
				,	MessageFormat			NVARCHAR(200)	NULL
				,	SPName					VARCHAR(200)	NULL
				,	CONSTRAINT	PK_ValidationRule PRIMARY KEY CLUSTERED (RuleId ASC) ON OWP_Data
				) ON OWP_Data;

-- Removed tables --
EXECUTE	sys.sp_rename 'dbo.[Column]', 'Column_old';

EXECUTE	sys.sp_rename 'dbo.RoleFunction', 'RoleFunction_old';

EXECUTE	sys.sp_rename 'dbo.FilterDetails', 'FilterDetails_old';

EXECUTE	sys.sp_rename 'dbo.Location', 'Location_old';

EXECUTE	sys.sp_rename 'dbo.Market', 'Market_old';

EXECUTE	sys.sp_rename 'dbo.MatchRecommendOdds', 'MatchRecommendOdds_Old';
EXECUTE	sys.sp_rename 'PK_MatchRecommendOdds_1', 'PK_MatchRecommendOdds_1_Old';

-- MatchRecommendOdds -- New --
CREATE TABLE	dbo.MatchRecommendOdds (
					MatchRecommendOddsId	INT				NOT NULL	IDENTITY(1, 1)
				,	OWPMatchId				INT				NOT NULL
				,	Bettype					INT				NOT NULL
				,	HDP						SMALLMONEY		NULL
				,	TeamChoice				TINYINT			NULL
				,	CreatedBy				INT				NOT NULL
				,	CreatedDate				DATETIME		NOT NULL	CONSTRAINT DF_MatchRecommendOdd_CreatedDate DEFAULT (GETDATE())
				,	CONSTRAINT	PK_MatchRecommendOdd PRIMARY KEY NONCLUSTERED (MatchRecommendOddsId ASC) ON OWP_Index
				) ON OWP_Data;

CREATE CLUSTERED INDEX	CIX_MatchRecommendOdds ON dbo.MatchRecommendOdds (
							OWPMatchId	ASC
						,	Bettype		ASC
						) ON OWP_Data;

-- MatchRecommendOddsDetail -- New --
CREATE TABLE	dbo.MatchRecommendOddsDetail (
					MatchRecommendOddsId	INT				NOT NULL
				,	Choice					TINYINT			NOT NULL
				,	Odds					MONEY			NULL
				,	CONSTRAINT	PK_MatchRecommendOddDetail PRIMARY KEY CLUSTERED (MatchRecommendOddsId ASC, Choice ASC) ON OWP_Data
				) ON OWP_Data;

-- NotificationSetting -- New --
CREATE TABLE	dbo.NotificationSetting (
					NotificationSettingId	SMALLINT		NOT NULL	IDENTITY(1, 1)
				,	Name					NVARCHAR(250)	NOT NULL
				,	IsWatcher				BIT				NOT NULL	CONSTRAINT DF_NotificationSetting_IsWatcher DEFAULT ((0))
				,	DefaultValue			NVARCHAR(250)	NULL
				,	CONSTRAINT	PK_NotificationSetting PRIMARY KEY CLUSTERED (NotificationSettingId ASC) ON OWP_Data
				) ON OWP_Data;

-- NotificationSettingMapping -- New --
CREATE TABLE	dbo.NotificationSettingMapping (
					NotificationSettingId	SMALLINT		NOT NULL
				,	UserId					INT				NOT NULL
				,	Value					NVARCHAR(250)	NOT NULL
				,	CONSTRAINT	PK_NotificationSettingMapping PRIMARY KEY CLUSTERED (NotificationSettingId ASC, UserId ASC) ON OWP_Data
				) ON OWP_Data;