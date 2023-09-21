
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Kpi_Get] @FromDate DATETIME, 
                                    @ToDate   DATETIME
AS

/*    
 Created: 20230829@Los
 Task : KPI report
 DB: bodb_OWP    
    
 Revisions:
	20230829@Carlos.nguyen: new column - [Redmine: #188514]
    20230829@Liam.Pham: get Target - [Redmine: #193488]
*/

     SET NOCOUNT ON;
     SELECT a.UserId, 
            u.Username, 
            (SUM(a.ESoccer15Mins) + SUM(a.ESoccer16Mins) + SUM(a.ESoccer20Mins) + SUM(a.ESoccer5MinsGroup) + CEILING(SUM(a.ESoccer6Mins) / 3)) AS VirtualMatches, 
            (SUM(a.TotalMatchInGroupMultiple) + SUM(a.OnlyProvider) + SUM(a.OnlyReporter) + SUM(a.OnlyTV) + SUM(a.MixedProviderTVReporter) + SUM(a.Others)) AS MultipleMatches, 
            (SUM(a.CornerPlus) + SUM(a.TBookingPlus) + SUM(a.Fantasy) + SUM(a.GoalKick) + SUM(a.OtherProducts)) AS SpecialProducts, 
            (SUM(a.FTCorner5ML) + SUM(a.FiveMajorLeague)) AS FiveMajorLeagues, 
            (SUM(a.FTCorner) + SUM(a.FTCorner5ML)) AS MultipleProducts, 
            r.[Value] 'Target', 
            t.TargetId
     FROM dbo.LAReport a
          INNER JOIN dbo.[User] u ON u.UserId = a.UserId
          LEFT JOIN LATargetSetting t WITH(NOLOCK) ON u.UserId = t.UserId
          LEFT JOIN RefResource r WITH(NOLOCK) ON r.RefName = 'LaKpiLevel'
                                                  AND r.ResourceId = t.TargetId
     WHERE a.ReportDate BETWEEN @FromDate AND @ToDate
     GROUP BY a.UserId, 
              r.[Value], 
              t.TargetId, 
              u.UserName
     ORDER BY u.Username ASC;