
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetReportByDateRange] @TraderName NVARCHAR(30), 
                                                                @Location   NVARCHAR(10) = NULL, 
                                                                @FromDate   DATE, 
                                                                @ToDate     DATE
AS

/*    
Created: 20211014@Mira
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20211014@Mira: init sp - [Redmine: #162821]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @SecionLiveTradingVN INT= 3;
        DECLARE @SecionLiveTradingPH INT= 28;
        CREATE TABLE #tmpUserId
        (Location VARCHAR(10), 
         UserId   INT, 
         Username VARCHAR(30),
        );

        -- Get Overtime report Data  
        INSERT INTO #tmpUserId
        (Location, 
         UserId, 
         Username
        )
               SELECT DISTINCT 
                      u.[LocationCode], 
                      u.[UserId], 
                      u.[Username]
               FROM dbo.[User] u WITH(NOLOCK)
               WHERE u.SectionId IN(@SecionLiveTradingVN, @SecionLiveTradingPH)
               AND (u.Username LIKE '%' + @TraderName + '%'
                    OR u.Nickname LIKE '%' + @TraderName + '%')
               AND ((@Location IS NOT NULL
                     AND u.LocationCode LIKE '%' + @Location + '%')
                    OR (@Location IS NULL
                        AND u.LocationCode IS NULL))
               ORDER BY u.LocationCode, 
                        u.Username;

        --Select User info
        SELECT [Location], 
               [UserId], 
               [Username]
        FROM #tmpUserId;

        --Select Overtime report
        SELECT o.[UserId], 
               o.[ReportDate], 
               o.[Hour], 
               o.[IsOffDay]
        FROM dbo.OvertimeReport o WITH(NOLOCK)
             INNER JOIN #tmpUserId t ON t.UserId = o.UserId
        WHERE o.ReportDate BETWEEN @FromDate AND @ToDate
        ORDER BY o.UserId, 
                 o.ReportDate;

        -- DROP temp table
        DROP TABLE #tmpUserId;
    END;