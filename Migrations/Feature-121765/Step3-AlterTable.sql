/*
	Created: Tyler.Dang
	Date: 20191011
	Task: Create table UserRemark [Redmine: #121878]
	DB: bodb_OWP
*/

USE bodb_OWP

CREATE TABLE dbo.[UserRemark](
	[UserId] [int] NOT NULL,
	[Remark] [nvarchar](200) NULL,
	[Category] INT NOT NULL,
 CONSTRAINT [PK_UserRemark] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRemark_UserId_Category] ON [dbo].[UserRemark]
(
	[UserId] ASC,
	[Category] ASC
)
GO

INSERT INTO dbo.[UserRemark] (UserId, Remark, Category)
SELECT UserId, Note, 1
FROM dbo.[EmployeeWorkingShiftNote] WITH (NOLOCK)
GO

EXEC sp_rename 'EmployeeWorkingShiftNote.PK_EmployeeWorkingShiftNote', 'PK_EmployeeWorkingShiftNote_Old', 'INDEX'
GO

EXEC sp_rename 'EmployeeWorkingShiftNote', 'EmployeeWorkingShiftNote_Old'
GO

CREATE TABLE dbo.[EmployeeWorkingShiftNote](
	[EmployeeWorkingShiftNoteId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[Note] [nvarchar](4000) NOT NULL,
	[ShiftDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EmployeeWorkingShiftNote] PRIMARY KEY CLUSTERED 
(
	[EmployeeWorkingShiftNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO