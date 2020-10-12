/*
	Creator:	20181129@Kane.Le
	Task:		Init Data - [Redmine: #105667]
	Server:		DBOWP.bodb_OWP
*/

USE [bodb_OWP]
GO

-- InitData RefResource UserLevel
DELETE FROM  dbo.RefResource WHERE RefName='UserLevel'
GO

INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(10, 'UserLevel', 1, 'A+')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(11, 'UserLevel', 2, 'A')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(12, 'UserLevel', 3, 'B+')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(13, 'UserLevel', 4, 'B')
INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(14, 'UserLevel', 5, 'C')
GO

INSERT INTO dbo.RefResource (RefResourceId, RefName, ResourceId, Value) VALUES(1121, 'Section', 20, 'OS')
GO