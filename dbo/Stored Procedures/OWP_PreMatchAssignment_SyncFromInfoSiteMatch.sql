
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_SyncFromInfoSiteMatch]
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
        CREATE TABLE #tblLeague(OWPLeagueId INT);
        DECLARE @date DATE= CAST(DATEADD(HOUR, 12, GETDATE()) AS DATE);
        DECLARE @fromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @date), '12:00:00');
        DECLARE @toDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @date), '11:59:59');
        -- Temp table
        INSERT INTO #tblLeague(OWPLeagueId)
               SELECT DISTINCT 
                      l.OWPLeagueId
               FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
                    INNER JOIN OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueName = m.LeagueName
                    LEFT JOIN PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId
                                                                   AND pl.EventDate = @date
               WHERE m.EventDateTime BETWEEN @fromDate AND @toDate
                     AND pl.OWPLeagueId IS NULL;
        -- Insert 
        INSERT INTO [dbo].[PreMatchLeague]
        ([OWPLeagueId], 
         [EventDate], 
         [IsDay], 
         [IsDeleted], 
         [Remark]
        )
               SELECT OWPLeagueId, 
                      @date, 
                      1, -- day shift
                      0, 
                      NULL
               FROM #tblLeague
               UNION
               SELECT OWPLeagueId, 
                      @date, 
                      0, -- night shift
                      0, 
                      NULL
               FROM #tblLeague
               ORDER BY OWPLeagueId;
        DROP TABLE #tblLeague;
    END;