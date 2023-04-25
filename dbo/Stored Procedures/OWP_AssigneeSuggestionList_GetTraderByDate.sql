
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssigneeSuggestionList_GetTraderByDate] @EventDate DATE
AS

/*
Created: 20230324@Liam.Pham
Task : 
DB: bodb_OWP

Revisions:
   20230324@Liam.Pham: Initial - [Redmine: #185365]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '16:00:00');
        CREATE TABLE #tblUser
        (UserId             INT, 
         Username           NVARCHAR(30), 
         [Level]            INT, 
         [LevelLabel]       NVARCHAR(50), 
         [Group]            NVARCHAR(50), 
         [Role]             NVARCHAR(50), 
         [MaxMultipleGames] NVARCHAR(50),
        );
        INSERT INTO #tblUser
        (UserId, 
         Username, 
         [Level], 
         LevelLabel, 
         [Group], 
         [Role], 
         [MaxMultipleGames]
        )
               SELECT ou.UserId, 
                      ou.Username, 
                      ou.[Level], 
                      rl.[Value], 
                      rg.[Value], 
                      rr.[Value], 
                      mg.[value]
               FROM dbo.[User] AS ou WITH(NOLOCK)
                    LEFT JOIN dbo.UserRole AS ur WITH(NOLOCK) ON ur.UserId = ou.UserId
                    LEFT JOIN dbo.[RefResource] rr ON rr.ResourceId = ur.RoleId
                                                      AND rr.RefName = 'UserRole'
                    LEFT JOIN dbo.[RefResource] rg ON rg.ResourceId = ou.GroupId
                                                      AND rg.RefName = 'UserGroup'
                    LEFT JOIN dbo.[RefResource] rl ON rl.ResourceId = ou.[Level]
                                                      AND rl.RefName = 'UserLevel'
                    LEFT JOIN dbo.[RefResource] mg ON mg.ResourceId = ou.MultipleGamesId
                                                      AND mg.RefName = 'MultipleGames'
               WHERE SectionId IN(3, 28);
        SELECT DISTINCT 
               u.UserId, 
               u.Username, 
               u.[Role], 
               ws.ShiftStartTime, 
               ws.ShiftEndTime, 
               u.[Level], 
               u.LevelLabel, 
               u.[Group], 
               u.MaxMultipleGames, 
               c.Extension, 
               STUFF(
        (
            SELECT ',' + rb.Value
            FROM [UserBetTypePreferences] up
                 INNER JOIN dbo.[RefResource] rb ON rb.RefName = 'BetTypePreferences'
                                                    AND rb.ResourceId = up.BettypeId
            WHERE up.UserId = u.UserId FOR XML PATH('')
        ), 1, 1, '') 'MainBetType'
        FROM dbo.EmployeeWorkingShift AS ws WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH(NOLOCK) ON ws.ShiftId = c.ShiftId
                                                                           AND c.IsTimeShift = 1
             INNER JOIN #tblUser AS u ON ws.EmployeeId = u.UserId
        WHERE(ws.ShiftStartTime > @FromDate
              AND ws.ShiftStartTime <= @ToDate)
             OR (ws.ShiftEndTime > DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '02:00:00')
                 AND ws.ShiftEndTime <= @ToDate);
        DROP TABLE #tblUser;
    END;