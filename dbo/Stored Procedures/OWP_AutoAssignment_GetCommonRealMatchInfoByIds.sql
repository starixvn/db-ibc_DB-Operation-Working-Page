USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetCommonRealMatchInfoByIds]    Script Date: 11/29/2021 10:55:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetCommonRealMatchInfoByIds] @Ids VARCHAR(MAX)
AS
/*
Created: 20211119@carlos.Nguyen
Task : Get match list by ids for auto assignment
DB: bodb_OWP

Revisions:
	20211119@carlos.Nguyen: Initial SP - [Redmine: #163362]
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @tempMatch TABLE(InfoSiteId INT);
	
	 INSERT INTO @tempMatch
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Ids, ',') u OPTION(MAXRECURSION 0);
		
	CREATE TABLE #tblInfositeMatch(
		InfoSiteId INT,
		LeagueName NVARCHAR(2000),
		Tv NVARCHAR(2000),
		KOTime DATETIME,
		Provider NVARCHAR(2000),
		IsSoloMatch BIT,
		IsMajorLeague BIT,
		Remark NVARCHAR(500),
		OtherProvider NVARCHAR(2000),
		Location NVARCHAR(2000),
		Channel NVARCHAR(500),
	)
	
	INSERT INTO #tblInfositeMatch(
		InfoSiteId,
		LeagueName,
		Tv,
		KOTime,
		Provider,
		IsSoloMatch,
		IsMajorLeague,
		Remark,
		OtherProvider,
		Location,
		Channel
	)
	SELECT DISTINCT im.InfoSiteMatchId,
		im.LeagueName,
		im.TV,
		im.EventDateTime,
		im.Provider,
		CASE WHEN tmp.InfoSiteId IN (SELECT InfoSiteId FROM InfoSiteSoloMatch) THEN 1 ELSE 0 END,
		CASE WHEN l.CategoryId = 1 THEN 1 ELSE 0 END,
		im.Remark,
		im.OtherProvider,
		im.Venue,
		im.Channel
	FROM @tempMatch AS tmp
		INNER JOIN InfoSiteMatch AS im ON tmp.InfoSiteId=im.InfoSiteMatchId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON im.OWPLeagueId = l.OWPLeagueId
	DROP TABLE #tblInfositeMatch
END
