
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGame_GetAdminSiteIdByOwpMatchId] @ParentMatchIds NVARCHAR(MAX) = NULL
AS

/*
Created: 20230417@Johnny
Task : Get InfoSiteTime
DB: bodb_OWP

Revisions:
	20230424@Johnny: Initial SP - [Redmine: #185886]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @MatchId TABLE(ParentMatchId INT);
        INSERT INTO @MatchId(ParentMatchId)
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@ParentMatchIds, ',');
        SELECT m.ParentMatchId, 
               om.MatchId as AdminSiteMatchId
        FROM @MatchId AS m
             INNER JOIN OWPMatch AS om WITH(NOLOCK) ON m.ParentMatchId = om.OWPMatchId;
    END;