/*
	Created: Carlos.Nguyen
	Date: 20191011
	Task: Add Group User [Redmine: #121885]
	DB: bodb_OWP
*/
USE bodb_OWP
INSERT INTO dbo.RefResource(RefName, ResourceId, Value, [Order])
VALUES ('UserGroup',1,'C_LG',1),
	('UserGroup',2,'C_LG(Special Team)',2),
	('UserGroup',3,'C_LG(Support Team)',3),
	('UserGroup',4,'S_LG',4),
	('UserGroup',5,'S_LG(Special Team)',5),
	('UserGroup',6,'SUPPORT TEAM',6)
GO


