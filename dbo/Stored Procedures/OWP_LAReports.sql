
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LAReports] @FromDate DATETIME = '2020-01-03', 
                                      @ToDate   DATETIME = '2020-01-05'
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
*/

     SET NOCOUNT ON;
     SELECT a.UserId, 
            a.Username, 
            r.Value Section, 
            SUM(a.TotalMatches) TotalMatches, 
            SUM(a.LinkLowerThan3) LinkLowerThan3, 
            SUM(a.LinkX3) LinkX3, 
            SUM(a.LinkX6) LinkX6, 
            SUM(a.LinkX9Plus) LinkX9Plus, 
            SUM(a.ProviderTv) ProviderTv, 
            SUM(a.Provider) Provider, 
            SUM(a.TV) TV, 
            SUM(a.Reporter) Reporter, 
            SUM(a.CornerPlus) CornerPlus, 
            SUM(a.Reporter) Reporter, 
            SUM(a.CornerPlus) CornerPlus, 
            SUM(a.TBookingPlus) TBookingPlus, 
            SUM(a.Fantasy) Fantasy, 
            SUM(a.GoalKick) GoalKick, 
            SUM(a.OtherProducts) OtherProducts, 
            SUM(a.FTCorner) FTCorner, 
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
     WHERE a.ReportDate BETWEEN @FromDate AND @ToDate
     GROUP BY a.UserId, 
              a.Username, 
              r.Value
     ORDER BY r.Value ASC, 
              a.Username ASC;