/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchNotification_QueryInfoSiteMatchByOWPLeagueIds] @OWPLeagueIds NVARCHAR(MAX), 
                                                                                   @FromDate     DATETIME, 
                                                                                   @ToDate       DATETIME
AS

/*  
Created: 20210615@Tyler.Dang  
Task :PreMatch notification
DB: bodb_OWP  
  
Revisions:  
 20210615@Tyler.Dang: query league InfoSiteMatch  - [Redmine: #156321]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempOWPLeagueId TABLE(OWPLeagueId INT);
        INSERT INTO @tempOWPLeagueId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@OWPLeagueIds, ',') u OPTION(MAXRECURSION 0);

        SELECT DISTINCT 
               im.OWPLeagueId, 
               im.EventDateTime
        FROM [dbo].InfoSiteMatch AS im WITH(NOLOCK)
             INNER JOIN @tempOWPLeagueId t ON t.OWPLeagueId = im.OWPLeagueId
        WHERE im.EventDateTime >= @FromDate
              AND im.EventDateTime <= @ToDate;
    END;