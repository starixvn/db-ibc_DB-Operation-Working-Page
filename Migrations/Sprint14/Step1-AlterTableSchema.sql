/*
	Created: Kane.Le
	Date: 20190402
	Task: [Redmine: #111068]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema
--------------------------------
USE bodb_OWP

-- add column IsSecondAccount to table User
ALTER TABLE dbo.[User]
ADD IsSecondAccount BIT NOT NULL DEFAULT(0);

-- change columns data type
ALTER TABLE dbo.OWPLeague ALTER COLUMN OWPLeagueName NVARCHAR(500) NOT NULL;
--
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN LeagueName NVARCHAR(500) NOT NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN HomeName NVARCHAR(200) NOT NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN AwayName NVARCHAR(200) NOT NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN Channel NVARCHAR(100) NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN WB NVARCHAR(100) NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN Website1 NVARCHAR(1000) NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN Website2 NVARCHAR(1000) NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN Website3 NVARCHAR(1000) NULL;
ALTER TABLE dbo.InfoSiteMatch ALTER COLUMN Website4 NVARCHAR(1000) NULL;
----
ALTER TABLE dbo.AssignmentUploading ALTER COLUMN League NVARCHAR(500) NOT NULL;
ALTER TABLE dbo.AssignmentUploading ALTER COLUMN Home NVARCHAR(200) NOT NULL;
ALTER TABLE dbo.AssignmentUploading ALTER COLUMN Away NVARCHAR(200) NOT NULL;

GO

DROP PROCEDURE dbo.OWP_EmployeeWorkingShift_Query
DROP PROCEDURE dbo.OWP_EmployeeWorkingShift_QueryByDate
GO