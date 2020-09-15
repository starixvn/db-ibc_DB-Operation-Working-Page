
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveDetail_ValidateInfoSiteMatchId] @MatchId         INT, 
                                                               @InfoSiteMatchId INT
AS

/*
Created: 20190820@Tyler.Dang
Task : Validate InfoSiteMatchId is existed or not
DB: bodb_OWP

Revisions:
	20190820@Tyler.Dang: InitialSP - [Redmine: #118566]
	20200913@Jacob: Sync Live Status to InfoSite - [Redmine: #134336]
*/

     SET NOCOUNT ON;
     DECLARE @owpIsLive BIT;
     DECLARE @infoSiteIsLive BIT;

     -- @owpIsLive
     SELECT @owpIsLive = CASE
                             WHEN mi.MatchStatus IN('Live', 'Postponed')
                             THEN 1
                             ELSE 0
                         END
     FROM dbo.OWPMatch AS om WITH(NOLOCK)
          INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
     WHERE om.OWPMatchId = @MatchId;

     -- @infoSiteIsLive
     SELECT @infoSiteIsLive = IsLive
     FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
     WHERE im.InfoSiteMatchId = @InfoSiteMatchId;

     -- Result
     SELECT CASE
                WHEN @infoSiteIsLive IS NULL
                THEN 0
                ELSE 1
            END AS IsInfoSiteLinked,
            CASE
                WHEN @owpIsLive = @infoSiteIsLive
                THEN 1
                ELSE 0
            END AS IsLiveStatusSynchronized;