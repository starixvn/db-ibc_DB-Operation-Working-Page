
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_Kpi_Get] @FromDate DATETIME , 
                                      @ToDate   DATETIME
AS

/*    
 Created: 20230829@Los
 Task : KPI report
 DB: bodb_OWP    
    
 Revisions:
	20230829@Carlos.nguyen: new column - [Redmine: #188514]
*/

     SET NOCOUNT ON;
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
            SUM(a.ESoccer15Mins) + SUM(a.ESoccer16Mins)+SUM(a.ESoccer20Mins)+SUM(a.ESoccer5MinsGroup)+CEILING(SUM(a.ESoccer6Mins)/3), 
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
              u.Username, 
              r.Value