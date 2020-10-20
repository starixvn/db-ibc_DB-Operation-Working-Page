
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_GetLastUpdated @IsDay BIT = 1
AS

/*      
 Created: 20200819@Esther.Nguyen
 Task : Pre-match Assignment
 DB: bodb_OWP      
 
 Revisions:
    20200819@Esther.Nguyen: Init sp - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     DECLARE @logTime DATETIME;
     DECLARE @tblLogAction TABLE
     (ActionId INT
      PRIMARY KEY
     );
     INSERT INTO @tblLogAction(ActionId)
     VALUES(113), (114), (115), (116), (117), (119);
     IF(@IsDay = 1)
         BEGIN
             SELECT @logTime = MAX(LoggedDate)
             FROM UserLog AS ul WITH(NOLOCK)
                  INNER JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON l.PreMatchLeagueId = ul.ObjectId
                  INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
             WHERE l.IsDay = @IsDay
                   AND ul.ActionId <> 117;
         END;
         ELSE
         BEGIN
             SELECT @logTime = MAX(LoggedDate)
             FROM UserLog AS ul WITH(NOLOCK)
                  LEFT JOIN dbo.[PreMatchLeague] AS l WITH(NOLOCK) ON l.PreMatchLeagueId = ul.ObjectId
                  INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
             WHERE(ul.ActionId <> 117
                   AND l.IsDay = @IsDay)
                  OR ul.ActionId = 117;
         END;
     SELECT DISTINCT 
            DATEADD(HOUR, 12, @logTime) 'UpdatedTime', 
            u.Username
     FROM UserLog AS ul WITH(NOLOCK)
          INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = ul.CreatorId
     WHERE ul.LoggedDate = @logTime
     GROUP BY u.Username;