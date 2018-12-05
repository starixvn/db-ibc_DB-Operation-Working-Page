/*
	Creator:	20181129@Kane.Le
	Task:		Remove unsed SPs - [Redmine: #105043]
	Server:		DBOWP.bodb_OWP
*/

USE [bodb_OWP]
GO

-- remove unused SPs
DROP PROCEDURE dbo.OWP_EventMgt_MatchLinking
GO