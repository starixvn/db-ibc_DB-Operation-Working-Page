
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetMatchIdsByDateList] @FromDate DATETIME, 
                                                                     @ToDate   DATETIME
AS

/*
Created: 20201224@Jack
Task : Other Sport
DB: bodb_OWP

Revisions:
	20201224@Jack: Init SP [Redmine: #146962]
	20220629@Johnny: Get Info Old Match [Redmine: #174437]
*/

    BEGIN
        SET @FromDate = DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
        SET @ToDate = DATEADD(DAY, DATEDIFF(DAY, -1, @ToDate), '11:59:59');

        --Select OSMatchId
        SELECT m.OSMatchId, 
               m.AdminSiteMatchId, 
               m.Sport, 
               m.EventDate
        FROM dbo.[OSMatch] AS m
        WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;


