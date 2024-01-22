
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Kpi_Get] @FromDate   DATETIME, 
                                    @ToDate     DATETIME, 
                                    @SectionIds VARCHAR(100) = NULL, 
                                    @SiteId     INT, 
                                    @ActiveUser BIT, 
                                    @ResignUser BIT
AS

/*    
 Created: 20230829@Los
 Task : KPI report
 DB: bodb_OWP    
    
 Revisions:
	20230829@Carlos.nguyen: new column - [Redmine: #188514]
    20230829@Liam.Pham: get Target - [Redmine: #193488]
	20231005@Los: Caculate virtual match - [Redmine: #194499]
	20231005@Liam: Query by section - [Redmine: #195223]
	20231225@Carlos.nguyen: hide resign account - [Redmine: #198234]
	20230108@Carlos.nguyen: correct condition - [Redmine: #198234]
*/

     SET NOCOUNT ON;
     DECLARE @tempSection TABLE(SectionId SMALLINT);
     INSERT INTO @tempSection
            SELECT DISTINCT 
                   value
            FROM STRING_SPLIT(@SectionIds, ',');
     SELECT a.UserId, 
            u.Username, 
            ROUND((SUM(a.ESoccer15Mins) + SUM(a.ESoccer16Mins) + SUM(a.ESoccer20Mins) + SUM(a.ESoccer5Mins / 4) + SUM(a.ESoccer6Mins / 3)), 1) AS VirtualMatches, 
            (SUM(a.TotalMatchInGroupMultiple) + SUM(a.OnlyProvider) + SUM(a.OnlyReporter) + SUM(a.OnlyTV) + SUM(a.MixedProviderTVReporter) + SUM(a.Others)) AS MultipleMatches, 
            (SUM(a.CornerPlus) + SUM(a.TBookingPlus) + SUM(a.Fantasy) + SUM(a.GoalKick) + SUM(a.OtherProducts)) AS SpecialProducts, 
            (SUM(a.FTCorner5ML) + SUM(a.FiveMajorLeague)) AS FiveMajorLeagues, 
            (SUM(a.FTCorner) + SUM(a.FTCorner5ML)) AS MultipleProducts, 
            r.[Value] 'Target', 
            t.TargetId,
            CASE
                WHEN rr.[Value] IS NULL
                THEN 'None'
                ELSE rr.[Value]
            END 'SectionName'
     FROM dbo.LAReport a WITH(NOLOCK)
          INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = a.UserId
          INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
          INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH(NOLOCK) ON us.UserId = u.UserId
                                                                                  AND us.SiteId = @SiteId
          INNER JOIN @tempSection temp ON(u.SectionId = temp.SectionId)
                                         OR (u.SectionId IS NULL
                                             AND temp.SectionId = 0)
          LEFT JOIN LATargetSetting t WITH(NOLOCK) ON u.UserId = t.UserId
          LEFT JOIN RefResource r WITH(NOLOCK) ON r.RefName = 'LaKpiLevel'
                                                  AND r.ResourceId = t.TargetId
          LEFT JOIN dbo.RefResource rr WITH(NOLOCK) ON u.SectionId = rr.ResourceId
                                                       AND RR.RefName = 'Section'
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
              r.[Value], 
              t.TargetId, 
              u.UserName, 
              rr.[Value]
     ORDER BY u.Username ASC;