
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LAReports] @FromDate    DATETIME     = '2020-01-03', 
                                      @ToDate      DATETIME     = '2020-01-05',  
                                      @ActiveUser  BIT, 
                                      @ResignUser  BIT, 
                                      @AllUserJson VARCHAR(MAX)
AS

/*    
 Created: 20200817@Mira
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200817@Mira: Archive plan for OWP tables - [Redmine: #137757]	
	20210113@Esther: Adding SABA 6mins match to LA Report - [Redmine: #148267]
	20210907@Liam: Adding SABA 16mins match to LA Report - [Redmine: #160544]
	20220408@Luca: Adding 5ML to LA Report - [Redmine:#171212]
	20220418@Liam: Adding FTCorner5ML to LA Report - [Redmine:#171212]
	20220920@Johnny: Change query LA Report - [Redmine:#177768]
	20230511@Carlos.nguyen: new column - [Redmine: #187937]
	20231225@Carlos.nguyen: hide resign account - [Redmine: #198234]
	20240925@Los: Remove NAP_UserControl [Redmine: #209152]
*/

     SET NOCOUNT ON;
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
     SELECT a.UserId, 
            u.Username, 
            r.Value Section, 
            SUM(a.TotalMatches) TotalMatches, 
            SUM(a.Link2) Link2, 
            SUM(a.Link3) Link3, 
            SUM(a.Link4) Link4, 
            SUM(a.Link5) Link5, 
            SUM(a.Link6) Link6, 
            SUM(a.Link7) Link7, 
            SUM(a.Link8Plus) Link8Plus, 
            SUM(a.TotalMatchInGroupMultiple) TotalMultiMatches, 
            SUM(a.OnlyProvider) OnlyProvider, 
            SUM(a.OnlyReporter) OnlyReporter, 
            SUM(a.OnlyTV) OnlyTV, 
            SUM(a.MixedProviderTVReporter) MixedProviderTVReporter, 
            SUM(a.CornerPlus) CornerPlus, 
            SUM(a.CornerPlus) CornerPlus, 
            SUM(a.TBookingPlus) TBookingPlus, 
            SUM(a.Fantasy) Fantasy, 
            SUM(a.GoalKick) GoalKick, 
            SUM(a.OtherProducts) OtherProducts, 
            SUM(a.FTCorner) FTCorner, 
            SUM(a.FTCorner5ML) FTCorner5ML, 
            SUM(a.FiveMajorLeague) FiveML, 
            SUM(a.ESoccer5Mins) ESoccer5Mins, 
            SUM(a.ESoccer6Mins) ESoccer6Mins, 
            SUM(a.ESoccer15Mins) ESoccer15Mins, 
            SUM(a.ESoccer16Mins) ESoccer16Mins, 
            SUM(a.ESoccer20Mins) ESoccer20Mins, 
            SUM(a.Others) Others
     FROM dbo.LAReport a
          LEFT JOIN dbo.[User] u ON u.UserId = a.UserId
          LEFT JOIN dbo.RefResource r ON r.RefName = 'Section'
                                         AND u.SectionId = r.ResourceId
          INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
          INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
     WHERE((@ActiveUser = 1
            AND ci.closed = 0
            AND ci.reject = 0
            AND ci.[Enabled] = 1
            AND us.IsActive = 1)
           OR (@ResignUser = 1
               AND (ci.closed = 1
                    OR ci.reject = 1
                    OR ci.[Enabled] = 0
                    OR us.IsActive = 0)))
          AND a.ReportDate BETWEEN @FromDate AND @ToDate
     GROUP BY a.UserId, 
              u.Username, 
              r.Value
     ORDER BY r.Value ASC, 
              u.Username ASC;