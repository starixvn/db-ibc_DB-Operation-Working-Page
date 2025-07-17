/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250717@Hank
Task : New table user setting
DB: bodb_OWP	

Revisions:
	20250717@Hank: New table user setting - [Redmine: #233295]
*/

CREATE TABLE [dbo].[UserSetting](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int]  NOT NULL,
	[Key] [nvarchar](max) NOT NULL,
	[Value] [nvarchar](max) NOT NULL
 CONSTRAINT [PK_UserSetting] PRIMARY KEY CLUSTERED 
(
	Id ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
) ON [OWP_Data] TEXTIMAGE_ON [OWP_Data]

GO