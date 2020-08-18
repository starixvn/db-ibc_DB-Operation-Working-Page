
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReports] @FromDate DATETIME = '2020-01-03', 
                                          @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200817@Mira
 Task : LA Reports
 DB: bodb_OWP    
    
 Revisions:
	20200817@Mira: Archive plan for OWP tables - [Redmine: #137757]	
*/

     SET NOCOUNT ON;
     SELECT rp.[UserId], 
            rp.[Username], 
            u.[SectionId], 
            rs.[Value] AS SectionName, 
            SUM([TotalMatch]) AS [TotalMatch], 
            SUM([Type1_FT_HDP]) AS [Type1_FT_HDP], 
            SUM([Type1_FT_OU]) AS [Type1_FT_OU], 
            SUM([Type1_FT_HDPOU]) AS [Type1_FT_HDPOU], 
            SUM([Type2_AUS_League]) AS [Type2_AUS_League], 
            SUM([Type2_AUS_League_Corner]) AS [Type2_AUS_League_Corner], 
            SUM([Type2_JAP_Divison1]) AS [Type2_JAP_Divison1], 
            SUM([Type2_JAP_Divison2]) AS [Type2_JAP_Divison2], 
            SUM([Type3_Solo_Major]) AS [Type3_Solo_Major], 
            SUM([Type4_Major]) AS [Type4_Major], 
            SUM([Type4_Minor1]) AS [Type4_Minor1], 
            SUM([Type4_Minor2]) AS [Type4_Minor2], 
            SUM([Type4_Minor3]) AS [Type4_Minor3], 
            SUM([Type4_1ST_Major]) AS [Type4_1ST_Major], 
            SUM([Type4_1ST_Other]) AS [Type4_1ST_Other], 
            SUM([Type4_Fantasy]) AS [Type4_Fantasy], 
            SUM([Type4_Corner_NextCorner]) AS [Type4_Corner_NextCorner], 
            SUM([Type4_15M]) AS [Type4_15M], 
            SUM([Type4_10M]) AS [Type4_10M], 
            SUM([Type4_TotalBooking]) AS [Type4_TotalBooking], 
            SUM([Type4_PKSO]) AS [Type4_PKSO], 
            SUM([Type4_Winner]) AS [Type4_Winner], 
            SUM([PH_1X2_Major]) AS [PH_1X2_Major], 
            SUM([PH_1X2_Minor1]) AS [PH_1X2_Minor1], 
            SUM([PH_1X2_Minor2]) AS [PH_1X2_Minor2], 
            SUM([PH_1X2_Minor3]) AS [PH_1X2_Minor3], 
            SUM([PH_1X2_Others]) AS [PH_1X2_Others], 
            SUM([Robot3_X2]) AS [Robot3_X2], 
            SUM([Robot3_X3]) AS [Robot3_X3], 
            SUM([Robot3_X3_Plus]) AS [Robot3_X3_Plus], 
            SUM([Robot5_X5]) AS [Robot5_X5]
     FROM dbo.TraderReport AS rp WITH(NOLOCK)
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON rp.UserId = u.UserId
          INNER JOIN dbo.[RefResource] AS rs WITH(NOLOCK) ON u.SectionId = rs.ResourceId
     WHERE rp.ReportDate >= @FromDate
           AND rp.ReportDate <= @ToDate
           AND rs.RefName = 'Section'
     GROUP BY rp.[UserId], 
              rp.[Username], 
              u.[SectionId], 
              rs.[Value]
     ORDER BY [SectionId], 
              [Username];