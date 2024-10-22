
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

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
	20200913@Jacob: Sync Live Status to InfoSite - Ignore deleted match - [Redmine: #134336]
	20210810@Mira: Sync Special Product Match - [Redmine: #153498]
*/

     SET NOCOUNT ON;
     DECLARE @owpIsLive BIT;
     DECLARE @adminSiteId INT;
     DECLARE @minorBettypeId INT;
     DECLARE @isInfoSiteLinked BIT;
     DECLARE @infositeParentId INT;

     -- @owpIsLive
     SELECT @owpIsLive = CASE
                             WHEN mi.MatchStatus IN('Live', 'Postponed')
                             THEN 1
                             ELSE 0
                         END, 
            @minorBettypeId = minor.MinorBettypeId, 
            @infositeParentId = CASE
                                    WHEN minor.ParentMatchId IS NULL
                                    THEN om.InfoSiteMatchId
                                    ELSE mp.InfoSiteMatchId
                                END
     FROM dbo.OWPMatch AS om WITH(NOLOCK)
          INNER JOIN dbo.MatchInfo AS mi WITH(NOLOCK) ON om.OWPMatchId = mi.OWPMatchId
          LEFT JOIN dbo.MinorMatch AS minor WITH(NOLOCK) ON om.OWPMatchId = minor.MinorMatchId
          LEFT JOIN dbo.OWPMatch mp WITH(NOLOCK) ON mp.OWPMatchId = minor.ParentMatchId
          LEFT JOIN dbo.InfoSiteMatch AS imn WITH(NOLOCK) ON mp.InfoSiteMatchId = imn.InfoSiteMatchId
                                                             AND imn.IsDeleted = 0
     WHERE om.OWPMatchId = @MatchId;

     -- @infoSiteIsLive
     SELECT @isInfoSiteLinked = IsLive
     FROM dbo.InfoSiteMatch AS im WITH(NOLOCK)
     WHERE im.InfoSiteMatchId = @InfoSiteMatchId
           AND im.IsDeleted = 0;

     -- @adminSiteId
     SELECT @adminSiteId = AdminSiteMatchId
     FROM InfoSiteMatch i
     WHERE i.InfoSiteMatchId = @infositeParentId
           AND i.IsDeleted = 0;

     -- Result
     SELECT CASE
                WHEN @isInfoSiteLinked IS NULL
                THEN 0
                ELSE 1
            END AS IsInfoSiteLinked, 
            @owpIsLive AS IsLiveMatchStatus, 
            @minorBettypeId AS MinorBettypeId, 
            @adminSiteId AS ParentAdminSiteId;