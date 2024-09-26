
/*<info serverAlias="DBACC-bodb02" executers="wsv_nap" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PrematchAssignment_GetMaxbetSpread] @AdminSiteMatchId NVARCHAR(MAX)
AS

/*
Created: 20220915@Carlos.Nguyen
Task: Get trader
DB: bodb_OWP

Revisions:
	20201203@Carlos.Nguyen: Get maxbet spread - [Redmine: #159110]
	20221031@Carlos.Nguyen: Fix deadlock- [Redmine:179779]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatch TABLE(MatchId INT);
        DECLARE @hdp INT= 1;
        DECLARE @ou INT= 3;
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@AdminSiteMatchId, ',');
        SELECT odd.matchid AS AdminSiteMatchId, 
               odd.bettype AS Bettype, 
               odd.maxbet AS Maxbet, 
               odd.oddsspreada AS Spread
        FROM bodb02.dbo.odds AS odd WITH (NOLOCK)
             INNER JOIN @tempMatch AS tplm ON odd.matchid = tplm.MatchId
        WHERE odd.liveindicator = 0
              AND odd.bettype IN(@hdp, @ou)
             AND odd.sort = 1;
    END;