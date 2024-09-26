
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGame_GetInfoSiteTime] @ParentMatchIds NVARCHAR(MAX) = NULL
AS

/*
Created: 20230417@Johnny
Task : Get InfoSiteTime
DB: bodb_OWP

Revisions:
	20230417@Johnny: Initial SP - [Redmine: #185886]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @MatchId TABLE(ParentMatchId INT);
        INSERT INTO @MatchId(ParentMatchId)
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@ParentMatchIds, ',');
        SELECT m.ParentMatchId, 
				i.EventDateTime,
               CONVERT(TIME, i.EventDateTime) AS KickOffTime
        FROM @MatchId AS m
             INNER JOIN OWPMatch AS om WITH(NOLOCK) ON m.ParentMatchId = om.OWPMatchId
             INNER JOIN InfoSiteMatch AS i WITH(NOLOCK) ON om.InfoSiteMatchId = i.InfoSiteMatchId;
    END;