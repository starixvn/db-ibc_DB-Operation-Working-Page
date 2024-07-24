
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240521@Mira
Task : Account Setting page
DB: bodb_OWP

Revisions:
	20240521@Mira: create new table for Account Setting Page - [Redmine: #201603]
*/

-- new table QuickMessage
CREATE TABLE dbo.QuickMessage
(Id          INT IDENTITY(1, 1) , 
 Shortcut    NVARCHAR(100) NOT NULL, 
 [Message]   NVARCHAR(1000) NOT NULL, 
 CreatedDate DATETIME NOT NULL, 
 CreatorId   INT NOT NULL
 CONSTRAINT [PK_QuickMessage] PRIMARY KEY CLUSTERED ([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];

-- new table UserProfile
CREATE TABLE dbo.UserProfile
(UserId INT  NOT NULL , 
 FileId INT NULL
 CONSTRAINT [PK_UserProfile] PRIMARY KEY CLUSTERED ([UserId] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];

-- new table IconMessage
CREATE TABLE dbo.MessageIcon
(Id        INT IDENTITY(1, 1) , 
 MessageId INT NOT NULL, 
 IconKey   NVARCHAR(200), 
 CreatorId INT,
 CONSTRAINT [PK_MessageIcon] PRIMARY KEY CLUSTERED ([Id] ASC)
  WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
)
ON [OWP_Data];