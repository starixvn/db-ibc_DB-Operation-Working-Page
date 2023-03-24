/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TodaySuggestionList_GetTraderByDate] @EventDate DATE
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
        (UserId        INT, 
         Username      NVARCHAR(30), 
         [Level]       INT, 
         [LevelLabel]  NVARCHAR(50), 
         [Group]       NVARCHAR(50), 
         [MainBettype] VARCHAR(10), 
         [Location]    NVARCHAR(10)
        );
        INSERT INTO #tblUser
        (UserId, 
         Username, 
         [Level], 
         LevelLabel, 
         [Group], 
         [MainBettype], 
         [Location]
        )
               SELECT ou.UserId, 
                      ou.Username, 
                      ou.[Level], 
                      rl.[Value], 
                      rg.[Value], 
                      rb.[Value], 
                      ou.LocationCode
               FROM dbo.[User] AS ou WITH(NOLOCK)
                    LEFT JOIN dbo.UserRole AS ur WITH(NOLOCK) ON ur.UserId = ou.UserId
                    LEFT JOIN dbo.[RefResource] rg ON rg.ResourceId = ou.GroupId
                                                      AND rg.RefName = 'UserGroup'
                    LEFT JOIN dbo.[RefResource] rl ON rl.ResourceId = ou.[Level]
                                                      AND rl.RefName = 'UserLevel'
                    LEFT JOIN dbo.[UserBetTypePreferences] up ON ou.UserId = up.UserId
                    LEFT JOIN dbo.[RefResource] rb ON rb.RefName = 'BetTypePreferences'
                                                      AND rb.ResourceId = up.BettypeId
               WHERE SectionId IN(3, 28);
        SELECT DISTINCT 
               u.UserId, 
               u.Username, 
               ws.ShiftStartTime, 
               ws.ShiftEndTime, 
               u.[Level], 
               u.LevelLabel, 
               u.[Group], 
               u.[MainBettype], 
               u.[Location]
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

 