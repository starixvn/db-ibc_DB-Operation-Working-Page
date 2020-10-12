/*
	Created: Leo.Vo
	Date: 20190717
	Task: [Redmine: #117098]
	DB: bodb_OWP
*/
USE bodb_OWP

ALTER TABLE dbo.RefResource
ADD [Order]     SMALLINT  CONSTRAINT [DF_RefResource_Order] DEFAULT (0) NOT NULL

GO

ALTER TABLE dbo.AssignmentUploadingLog
ADD [TotalRowUpload]     SMALLINT  CONSTRAINT [DF_AssignmentUploadingLog_TotalRowUpload] DEFAULT (0) NOT NULL

GO

INSERT INTO dbo.[RefResource] (RefName, ResourceId, [Value], [Order])
SELECT 'UserRole', RoleId, RoleName, RoleId
FROM dbo.[Role]
GO