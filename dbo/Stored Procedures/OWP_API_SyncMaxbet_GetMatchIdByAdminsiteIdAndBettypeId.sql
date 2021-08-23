USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_API_SyncMaxbet_GetMatchIdByAdminsiteId.sql]    Script Date: 12/04/2020 13:20:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMatchIdByAdminsiteIdAndBettypeId]
	@AdminsiteId INT,
	@BettypeId INT
AS
/*
Created: 20210811@Carlos.Nguyen
Task: Get match id by adminsite id & bettypeId
DB: bodb_OWP

Revisions:
	20210811@Carlos.Nguyen: Get match id by adminsite id & bettypeId - [Redmine: #153498]
*/
BEGIN
	SET NOCOUNT ON
	SELECT TOP 1 mm.MinorMatchId AS OwpMatchId
	FROM OWPMatch AS om WITH (NOLOCK)
		INNER JOIN MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.ParentMatchId
	WHERE om.MatchId=@AdminsiteId AND mm.MinorBettypeId=@BettypeId
	AND om.EventDate=DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
	ORDER BY om.EventDateTime DESC
END