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
	20211004@Carlos.Nguyen: Get latest match Id in timae range [Redmine: #162609]
	20211118@Luca.Duong: Get latest minor match id and main match id [Redmine: #163030]
	20211118@Carlos.nguyen: Get latest minor match id and main match id [Redmine: #163030]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00')
	DECLARE @ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -2, @FromDate), '11:59:59')
	
	SELECT TOP 1 mm.MinorMatchId,
		mm.ParentMatchId
	FROM OWPMatch AS om WITH (NOLOCK)
		INNER JOIN MinorMatch AS mm WITH (NOLOCK) ON om.OWPMatchId = mm.ParentMatchId
	WHERE om.MatchId=@AdminsiteId AND mm.MinorBettypeId=@BettypeId
	AND om.EventDateTime BETWEEN @FromDate AND @ToDate
	ORDER BY om.EventDateTime DESC
END