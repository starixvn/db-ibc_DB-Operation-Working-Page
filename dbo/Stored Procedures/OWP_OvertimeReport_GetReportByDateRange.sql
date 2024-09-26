
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OvertimeReport_GetReportByDateRange] @TraderName  NVARCHAR(30), 
                                                                @Location    NVARCHAR(10), 
                                                                @FromDate    DATE, 
                                                                @ToDate      DATE, 
                                                                @AllUserJson VARCHAR(MAX)
AS

/*    
Created: 20211014@Mira
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20211014@Mira: init sp - [Redmine: #162821]
	20240925@Los: Remove NAP_UserControl [Redmine: #209152]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @SecionLiveTradingVN INT= 3;
        DECLARE @SecionLiveTradingPH INT= 28;
        DECLARE @tblAllUser TABLE
        (UserId   INT NOT NULL, 
         IsActive BIT
        );
        INSERT INTO @tblAllUser
        (UserId, 
         IsActive
        )
               SELECT *
               FROM OPENJSON(@AllUserJson) WITH(UserId INT, IsActive BIT);
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
                    INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
                    INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
               WHERE u.SectionId IN(@SecionLiveTradingVN, @SecionLiveTradingPH)
                    AND (u.Username LIKE '%' + @TraderName + '%'
                         OR u.Nickname LIKE '%' + @TraderName + '%')
                    AND (@Location = 'All'
                         OR (@Location = 'None'
                             AND u.LocationCode IS NULL)
                         OR u.LocationCode = @Location)
                    AND ci.closed = 0
                    AND ci.reject = 0
                    AND ci.[Enabled] = 1
                    AND us.IsActive = 1
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