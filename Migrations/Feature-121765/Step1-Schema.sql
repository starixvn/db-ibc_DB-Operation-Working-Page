/*
	Created: Kane.Le
	Date: 20191011
	Task: schema [Redmine: #121765]
	DB: bodb_OWP
*/
USE bodb_OWP
GO

-- add column status code for auto assignment
ALTER TABLE [AutoAssignmentResult]
ADD StatusCode INT

-- add user group
ALTER TABLE dbo.[User]
ADD GroupId INT

GO

-- add user ws remark
CREATE TABLE dbo.[UserRemark](
	[UserId] [int] NOT NULL,
	[Category] INT NOT NULL,
	[Remark] [nvarchar](200)
)

CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRemark_UserId_Category] ON [dbo].[UserRemark]
(
	[UserId] ASC,
	[Category] ASC
)
GO

-- add user ws note
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
	CONSTRAINT [PK_EmployeeWorkingShiftNoteId] PRIMARY KEY CLUSTERED ([EmployeeWorkingShiftNoteId] ASC)
)

CREATE NONCLUSTERED INDEX [IX_EmployeeWorkingShiftNote_UserId_ShiftDate] ON [dbo].[EmployeeWorkingShiftNote]
(
	[UserId] ASC,
	[ShiftDate] ASC
)
GO
