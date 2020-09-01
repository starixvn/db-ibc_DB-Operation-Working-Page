
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetLastUpdated] @IsDay BIT = 1
AS

/*      
 Created: 20200819@Esther.Nguyen
 Task : Pre-match Assignment
 DB: bodb_OWP      
 
 Revisions:
    20200819@Esther.Nguyen: Init sp - [Redmine: #138643]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @logTime DATETIME;
        DECLARE @tblLogAction TABLE
        (ActionId INT
         PRIMARY KEY
        );

        INSERT INTO @tblLogAction(ActionId)
        VALUES(113), (114), (115), (116), (117);

        SELECT @logTime = MAX(LoggedDate)
        FROM UserLog AS ul WITH(NOLOCK)
             INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId;

        SELECT DISTINCT 
               DATEADD(HOUR, 12, @logTime) 'UpdatedTime', 
               u.Username
        FROM UserLog AS ul WITH(NOLOCK)
             INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = ul.CreatorId
             INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON l.PreMatchLeagueId = ul.ObjectId
        WHERE ul.LoggedDate = @logTime
              AND l.IsDay = @IsDay
        GROUP BY u.Username;
    END;