
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240822@Carlos.nguyen
Task : Archive ticket
DB: bodb_OWP

Revisions:
	20240822@Los: Archive ticket   - [Redmine: #207945]
*/

USE [bodb_OWP]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileUpload_Old](
	[FileId] [int] NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[SavedFileName] [nvarchar](200) NULL,
 CONSTRAINT [PK_FileUpload_Old] PRIMARY KEY CLUSTERED 
(
	[FileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
) ON [OWP_Data]

/****** Object:  Index [IX_CreatedDate]    Script Date: 8/22/2024 11:08:54 AM ******/
CREATE NONCLUSTERED INDEX [IX_CreatedDate] ON [dbo].[FileUpload_Old]
(
	[CreatedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]

GO
/****** Object:  Table [dbo].[TicketMessage]    Script Date: 8/22/2024 11:08:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TicketMessage_Old](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TicketId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Message] [nvarchar](2000) NOT NULL,
	[UserId] [int] NOT NULL,
	[IsSaved] [bit] NULL,
	[FileId] [int] NULL,
	[QuoteMessageId] [int] NULL,
CONSTRAINT [PK_TicketMessage_Old] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
) ON [OWP_Data]
GO

CREATE NONCLUSTERED INDEX [IX_TicketId_UserId_CreatedDate] ON [dbo].[TicketMessage_Old]
(
	[TicketId],
	[UserId],
	[CreatedDate]
)
GO
