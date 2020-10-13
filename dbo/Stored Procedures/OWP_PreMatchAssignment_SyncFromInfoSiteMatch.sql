
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_SyncFromInfoSiteMatch] @FromDate DATETIME, 
                                                                     @ToDate   DATETIME
AS

/*
Created: 20200813@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200813@Tyler: Init sync SP - [Redmine: #138643]
	20200923@Tyler: Update sync to future - [Redmine: #140620]	
	20201012@Jacob: HotFix Failed to show League that has matches with KO time AM only - [Redmine: #143299]	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tblLeague
     (RowId       INT IDENTITY(1, 1), 
      OWPLeagueId INT, 
      EventDate   DATE
     );
     SELECT @FromDate = DATEADD(HOUR, 12, @FromDate), 
            @ToDate = DATEADD(HOUR, 12, @ToDate);

     -- Temp table
     INSERT INTO #tblLeague
     (OWPLeagueId, 
      EventDate
     )
            SELECT DISTINCT 
                   m.OWPLeagueId, 
                   CAST(DATEADD(HOUR, -12, m.EventDateTime) AS DATE)
            FROM [dbo].[InfoSiteMatch] AS m WITH(NOLOCK)
                 LEFT JOIN PreMatchLeague AS pl WITH(NOLOCK) ON pl.OWPLeagueId = m.OWPLeagueId
                                                                AND pl.EventDate = CAST(DATEADD(HOUR, -12, m.EventDateTime) AS DATE)
            WHERE m.EventDateTime BETWEEN @FromDate AND @ToDate
                  AND pl.OWPLeagueId IS NULL;
     -- Insert Data
     INSERT INTO [dbo].[PreMatchLeague]
     ([OWPLeagueId], 
      [EventDate], 
      [IsDay], 
      [IsDeleted], 
      [Remark]
     )
            SELECT OWPLeagueId, 
                   EventDate, 
                   1, -- day shift
                   0, 
                   NULL
            FROM #tblLeague
            UNION
            SELECT OWPLeagueId, 
                   EventDate, 
                   0, -- night shift
                   0, 
                   NULL
            FROM #tblLeague
            ORDER BY OWPLeagueId;
     
	 -- DROP temp table
     DROP TABLE #tblLeague;