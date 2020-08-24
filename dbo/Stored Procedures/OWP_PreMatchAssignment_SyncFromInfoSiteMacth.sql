/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_SyncFromInfoSiteMacth]
AS

/*
Created: 20200813@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200813@Tyler: Init sync SP - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblLeague
        (RowId       INT IDENTITY(1, 1), 
         OWPLeagueId INT
        );
        DECLARE @i INT= 1;
        DECLARE @totalLeague INT;
        DECLARE @date DATE= CAST(GETDATE() AS DATE);
        DECLARE @fromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @date), '12:00:00');
        DECLARE @toDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @date), '11:59:59');
        INSERT INTO #tblLeague(OWPLeagueId)
               SELECT DISTINCT 
                      l.OWPLeagueId
               FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
                    INNER JOIN OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueName = m.LeagueName
                    LEFT JOIN PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId AND pl.EventDate = @date
               WHERE m.EventDateTime BETWEEN @fromDate AND @toDate
                     AND pl.OWPLeagueId IS NULL;
        SELECT @totalLeague = COUNT(OWPLeagueId)
        FROM #tblLeague;
        WHILE @i <= @totalLeague
            BEGIN
                DECLARE @leagueId INT;
                SELECT @leagueId = (OWPLeagueId)
                FROM #tblLeague
                WHERE RowId = @i;
                INSERT INTO [dbo].[PreMatchLeague]
                ([OWPLeagueId], 
                 [EventDate], 
                 [IsDay], 
                 [IsDeleted], 
                 [Remark]
                )
                VALUES
                (@leagueId, 
                 @date, 
                 1, 
                 0, 
                 NULL
                ),
				(@leagueId, 
                 @date, 
                 0, 
                 0, 
                 NULL
                );
                
                SET @i = @i + 1;
            END;
		DROP TABLE #tblLeague;
    END;