USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_API_SyncMaxbet_GetTraderXMins]    Script Date: 08/13/2021 14:12:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetTraderXMins] @OwpMatchId INT                                                        
AS

/*
Created: 20210813@Carlos.Nguyen
Task: Get trader XMins
DB: bodb_OWP

Revisions:
	20210813@Carlos.Nguyen: Get trader XMins - [Redmine: #153498]
*/

BEGIN
    SET NOCOUNT ON

	SELECT am.UserId
	FROM Assignment AS am WITH (NOLOCK)
	WHERE am.OWPMatchId= @OwpMatchId AND am.AssignmentType=1
END;