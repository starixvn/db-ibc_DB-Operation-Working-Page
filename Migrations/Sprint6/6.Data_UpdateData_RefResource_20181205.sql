/*
	Creator:	20181205@Kane.Le
	Task:		Update Data - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/

USE [bodb_OWP]
GO

UPDATE dbo.RefResource SET [Value] = 'E' WHERE  RefResourceId=14
GO