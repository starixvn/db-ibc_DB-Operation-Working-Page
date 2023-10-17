
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Kpi_GetLogTargetLevel] @UserId INT
AS

/*
Created: 20230918@Mira
Task : LA KPI phase 2
DB: bodb_OWP	

Revisions:
	20231012@Mira: get log target - [Redmine: #195223]
*/

    BEGIN
        SET NOCOUNT ON;

        -- log info -- 
        SELECT DATEADD(hour, 12, ul.LoggedDate) AS ModifiedDate, 
               u.Username AS ModifiedBy, 
               ul.DataOld, 
               ul.Data
        FROM dbo.UserLog AS ul WITH(NOLOCK)
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId
        WHERE ul.ActionId = 131
              AND ul.ObjectId = @UserId
        ORDER BY ul.LoggedDate DESC;
    END;