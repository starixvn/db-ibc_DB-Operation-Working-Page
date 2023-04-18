
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGame_GetAdminSiteInfo] @ParentMatchIds NVARCHAR(MAX) = NULL
AS

/*
Created: 20230417@Johnny
Task : Get GetAdminSiteInfo
DB: bodb_OWP

Revisions:
	20230418@Johnny: Initial SP - [Redmine: #185886]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @MatchId TABLE(ParentMatchId INT);
        DECLARE @dateNow DATETIME;
        SET @dateNow = GETDATE();
        INSERT INTO @MatchId(ParentMatchId)
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@ParentMatchIds, ',');
        SELECT DISTINCT m.ParentMatchId,
               CASE
                   WHEN od.oddsstatus != 'running'
                        AND od.oddsstatus != NULL
                        AND @dateNow >= ma.GlobalShowTime
						AND ma.GlobalShowTime != NULL
						AND od.bettype = 1
                   THEN 1
                   ELSE 0
               END AS IsShowAbsenceIcon
        FROM @MatchId AS m
             INNER JOIN OWPMatch AS om WITH(NOLOCK) ON m.ParentMatchId = om.OWPMatchId
             LEFT JOIN bodb02.dbo.odds AS od WITH(NOLOCK) ON om.MatchId = od.matchid
             LEFT JOIN bodb02.dbo.[match] AS ma WITH(NOLOCK) ON om.MatchId = ma.matchid;
    END;