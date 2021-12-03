USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_API_SyncMaxbet_GetMatchIdByAdminsiteId.sql]    Script Date: 12/04/2020 13:20:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMatchIdByAdminsiteId] @AdminsiteId INT
AS
/*
Created: 20201203@Carlos.Nguyen
Task: Get match id by adminsite id
DB: bodb_OWP

Revisions:
	20201203@Carlos.Nguyen: Get match id by adminsite id - [Redmine: #145096]
	20210811@Carlos.Nguyen: Get match id by adminsite id [Redmine: #153498]
	20211004@Carlos.Nguyen: Get latest match Id in timae range [Redmine: #162609]
	20211118@Carlos.nguyen: Handle merge match [Redmine: #163030]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00')
	DECLARE @ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -2, @FromDate), '11:59:59')
	
	SELECT TOP 1 om.OWPMatchId
	FROM OWPMatch AS om WITH (NOLOCK)
		INNER JOIN InfoSiteMatch AS im WITH (NOLOCK) ON im.InfoSiteMatchId=om.InfoSiteMatchId
	WHERE im.AdminSiteMatchId=@AdminsiteId AND im.ParentId IS NULL
		AND om.EventDateTime BETWEEN @FromDate AND @ToDate
	ORDER BY om.EventDateTime DESC
END