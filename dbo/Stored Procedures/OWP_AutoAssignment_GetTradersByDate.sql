
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetTradersByDate] @EventDate DATE, 
                                                            @SiteId    INT
AS

/*  
Created: 20210511@Mira
Task : Auto trader assignment
DB: bodb_OWP  
  
Revisions:  
	 20210511@Mira: Initial SP - [Redmine: #132710]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        DECLARE @NullLevelId INT;
        CREATE TABLE #tblUser
        ([TraderId]            INT, 
         [Level]               INT, 
         [Role]                VARCHAR(20), 
         [BettypesPreferences] VARCHAR(10), 
         [MaxGames]            VARCHAR(10)
        );

        -- Select level
        SELECT @NullLevelId = MAX(ResourceId) + 1
        FROM dbo.RefResource WITH(NOLOCK)
        WHERE RefName = 'UserLevel';

        -- insert temp table user
        INSERT INTO #tblUser
        ([TraderId], 
         [Level], 
         [Role], 
         [BettypesPreferences], 
         [MaxGames]
        )
               SELECT ou.UserId, 
                      ou.[Level], 
                      r.[Value], 
                      rb.[Value], 
                      rm.[Value]
               FROM dbo.[User] AS ou WITH(NOLOCK)
                    LEFT JOIN dbo.UserRole AS ur WITH(NOLOCK) ON ur.UserId = ou.UserId
                    LEFT JOIN dbo.RefResource r WITH(NOLOCK) ON r.RefName = 'UserRole'
                                                                AND r.ResourceId = ou.SectionId
                    LEFT JOIN dbo.RefResource rb WITH(NOLOCK) ON rb.RefName = 'BetTypePreferences'
                                                                 AND rb.ResourceId = ou.BetTypePreferencesId
                    LEFT JOIN dbo.RefResource rm WITH(NOLOCK) ON rm.RefName = 'MultipleGames'
                                                                 AND rm.ResourceId = ou.BetTypePreferencesId
               WHERE ou.[Level] <> @NullLevelId
                     AND LocationCode IS NOT NULL
                     AND rb.[Value] IS NOT NULL -- Remove [BettypesPreferences] is NULL
                     AND ou.SectionId IN(3, 28); --'Live Trading-VN' and 'Live Trading-PH'
        SELECT DISTINCT 
               [TraderId], 
               [Level], 
               [Role], 
               [BettypesPreferences], 
               [MaxGames] 'MultipleGames'
        FROM #tblUser;

        -- select working shift
        SELECT DISTINCT 
               u.TraderId 'UserId', 
               (CASE
                    WHEN ws.ShiftStartTime < @FromDate
                    THEN @FromDate
                    ELSE ws.ShiftStartTime
                END) AS ShiftStartTime, 
               ws.ShiftEndTime
        FROM dbo.EmployeeWorkingShift AS ws WITH(NOLOCK)
             INNER JOIN dbo.EmployeeWorkingShiftColor AS c WITH(NOLOCK) ON ws.ShiftId = c.ShiftId
                                                                           AND c.IsTimeShift = 1
             INNER JOIN #tblUser AS u ON ws.EmployeeId = u.TraderId
        WHERE(ws.ShiftStartTime BETWEEN @FromDate AND @ToDate)
             OR (ws.ShiftEndTime BETWEEN @FromDate AND @ToDate);

        -- drop temp table
        DROP TABLE #tblUser;
    END;