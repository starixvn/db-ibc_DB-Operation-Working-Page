
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveGame_GetAdminSiteInfo]
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
        DECLARE @dateNow DATETIME;
        SET @dateNow = GETDATE();
        SELECT DISTINCT 
               od.matchid AS AdminSiteMatchId
        FROM dbo.[match] AS m WITH(NOLOCK)
             INNER JOIN dbo.odds AS od WITH(NOLOCK) ON m.matchid = od.matchid
        WHERE od.oddsstatus != 'running'
              AND @dateNow >= m.GlobalShowTime
              AND od.bettype = 1
              AND od.liveindicator = 1;
    END;