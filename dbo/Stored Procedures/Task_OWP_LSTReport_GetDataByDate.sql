/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[Task_OWP_LSTReport_GetDataByDate] @FromDate DATE
	,@ToDate DATE
AS
/*    
 Created: 20191211@Kane.Le
 Task : Caculate report by date of LST Report
 DB: bodb_OWP    
    
 Revisions:
	20191211@Kane.Le: Initial SP - [Redmine: #124448]	
*/
BEGIN
	 
	SET NOCOUNT ON;

	-- Run 3 day latest

	EXEC Task_OWP_LSTReport_CaculateByDate

	CREATE TABLE #tmpSectionResource (
		Id INT
		,Name NVARCHAR(50)
		)

	INSERT INTO #tmpSectionResource (
		Id
		,Name
		)
	SELECT ResourceId
		,Value
	FROM dbo.[RefResource] AS rs WITH (NOLOCK)
	WHERE rs.RefName = 'Section'

	SELECT rp.[UserId]
		,rp.[Username]
		,u.[SectionId]
		,rs.[Name] AS SectionName
		 
		,CASE WHEN SUM([TotalMatch]) > 0 THEN CAST(SUM( [TotalMatch]) AS VARCHAR) ELSE '-' END AS [TotalMatch]
		,CASE WHEN SUM([Type1_FT_HDP]) > 0 THEN CAST(SUM([Type1_FT_HDP]) AS VARCHAR) ELSE '-' END AS [Type1_FT_HDP]
		,CASE WHEN SUM([Type1_FT_OU]) > 0 THEN CAST(SUM([Type1_FT_OU]) AS VARCHAR) ELSE '-' END AS [Type1_FT_OU]
		,CASE WHEN SUM([Type1_FT_HDPOU]) > 0 THEN CAST(SUM([Type1_FT_HDPOU]) AS VARCHAR) ELSE '-' END AS [Type1_FT_HDPOU]
		,CASE WHEN SUM([Type2_AUS_League]) > 0 THEN CAST(SUM([Type2_AUS_League]) AS VARCHAR) ELSE '-' END AS [Type2_AUS_League]
		,CASE WHEN SUM([Type2_AUS_League_Corner]) > 0 THEN CAST(SUM([Type2_AUS_League_Corner]) AS VARCHAR) ELSE '-' END AS [Type2_AUS_League_Corner]
		,CASE WHEN SUM([Type2_JAP_Divison1]) > 0 THEN CAST(SUM([Type2_JAP_Divison1]) AS VARCHAR) ELSE '-' END AS [Type2_JAP_Divison1]
		,CASE WHEN SUM([Type2_JAP_Divison2]) > 0 THEN CAST(SUM([Type2_JAP_Divison2]) AS VARCHAR) ELSE '-' END AS [Type2_JAP_Divison2]
		,CASE WHEN SUM([Robot3_X2]) > 0 THEN CAST(SUM([Robot3_X2]) AS VARCHAR) ELSE '-' END AS [Robot3_X2]
		,CASE WHEN SUM([Robot3_X3]) > 0 THEN CAST(SUM([Robot3_X3]) AS VARCHAR) ELSE '-' END AS [Robot3_X3]
		,CASE WHEN SUM([Robot3_X3_Plus]) > 0 THEN CAST(SUM([Robot3_X3_Plus]) AS VARCHAR) ELSE '-' END AS [Robot3_X3_Plus]
		,CASE WHEN SUM([Type3_Solo_Major]) > 0 THEN CAST(SUM([Type3_Solo_Major]) AS VARCHAR) ELSE '-' END AS [Type3_Solo_Major]
		,CASE WHEN SUM([Type4_Major]) > 0 THEN CAST(SUM([Type4_Major]) AS VARCHAR) ELSE '-' END AS [Type4_Major]
		,CASE WHEN SUM([Type4_Minor1]) > 0 THEN CAST(SUM([Type4_Minor1]) AS VARCHAR) ELSE '-' END AS [Type4_Minor1]
		,CASE WHEN SUM([Type4_Minor2]) > 0 THEN CAST(SUM([Type4_Minor2]) AS VARCHAR) ELSE '-' END AS [Type4_Minor2]
		,CASE WHEN SUM([Type4_Minor3]) > 0 THEN CAST(SUM([Type4_Minor3]) AS VARCHAR) ELSE '-' END AS [Type4_Minor3]
		,CASE WHEN SUM([Type4_1ST_Major]) > 0 THEN CAST(SUM([Type4_1ST_Major]) AS VARCHAR) ELSE '-' END AS [Type4_1ST_Major]
		,CASE WHEN SUM([Type4_1ST_Other]) > 0 THEN CAST(SUM([Type4_1ST_Other]) AS VARCHAR) ELSE '-' END AS [Type4_1ST_Other]
		,CASE WHEN SUM([Type4_Fantasy]) > 0 THEN CAST(SUM([Type4_Fantasy]) AS VARCHAR) ELSE '-' END AS [Type4_Fantasy]
		,CASE WHEN SUM([Type4_Corner_NextCorner]) > 0 THEN CAST(SUM([Type4_Corner_NextCorner]) AS VARCHAR) ELSE '-' END AS [Type4_Corner_NextCorner]
		,CASE WHEN SUM([Type4_15M]) > 0 THEN CAST(SUM([Type4_15M]) AS VARCHAR) ELSE '-' END AS [Type4_15M]
		,CASE WHEN SUM([Type4_10M]) > 0 THEN CAST(SUM([Type4_10M]) AS VARCHAR) ELSE '-' END AS [Type4_10M]
		,CASE WHEN SUM([Type4_TotalBooking]) > 0 THEN CAST(SUM([Type4_TotalBooking]) AS VARCHAR) ELSE '-' END AS [Type4_TotalBooking]
		,CASE WHEN SUM([Type4_PKSO]) > 0 THEN CAST(SUM([Type4_PKSO]) AS VARCHAR) ELSE '-' END AS [Type4_PKSO]
		,CASE WHEN SUM([Type4_Winner]) > 0 THEN CAST(SUM([Type4_Winner]) AS VARCHAR) ELSE '-' END AS [Type4_Winner]
		,CASE WHEN SUM([PH_1X2_Major]) > 0 THEN CAST(SUM([PH_1X2_Major]) AS VARCHAR) ELSE '-' END AS [PH_1X2_Major]
		,CASE WHEN SUM([PH_1X2_Minor1]) > 0 THEN CAST(SUM([PH_1X2_Minor1]) AS VARCHAR) ELSE '-' END AS [PH_1X2_Minor1]
		,CASE WHEN SUM([PH_1X2_Minor2]) > 0 THEN CAST(SUM([PH_1X2_Minor2]) AS VARCHAR) ELSE '-' END AS [PH_1X2_Minor2]
		,CASE WHEN SUM([PH_1X2_Minor3]) > 0 THEN CAST(SUM([PH_1X2_Minor3]) AS VARCHAR) ELSE '-' END AS [PH_1X2_Minor3]
		,CASE WHEN SUM([PH_1X2_Others]) > 0 THEN CAST(SUM([PH_1X2_Others]) AS VARCHAR) ELSE '-' END AS [PH_1X2_Others]
		,CASE WHEN SUM([X5]) > 0 THEN CAST(SUM([X5]) AS VARCHAR) ELSE '-' END AS [X5]
		,SUM([TurnOver_FT_HDP]) AS [TurnOver_FT_HDP]
		,SUM([TurnOver_FT_OU]) AS [TurnOver_FT_OU]
		,SUM([TurnOver_1H_HDP]) AS [TurnOver_1H_HDP]
		,SUM([TurnOver_1H_OU]) AS [TurnOver_1H_OU]
		,SUM([TurnOver_Others]) AS [TurnOver_Others]
		,SUM([WinLoss_FT_HDP]) AS [WinLoss_FT_HDP]
		,SUM([Winloss_FT_OU]) AS [Winloss_FT_OU]
		,SUM([Winloss_1H_HDP]) AS [Winloss_1H_HDP]
		,SUM([Winloss_1H_OU]) AS [Winloss_1H_OU]
		,SUM([Winloss_Others]) AS [Winloss_Others]
	FROM dbo.LSTReport AS rp WITH (NOLOCK)
	JOIN dbo.[User] AS u WITH (NOLOCK) ON rp.UserId = u.UserId
	JOIN #tmpSectionResource AS rs ON rs.Id = u.SectionId
	WHERE rp.ReportDate >= @FromDate
		AND rp.ReportDate <= @ToDate
	GROUP BY rp.[UserId]
		,rp.[Username]
		,u.[SectionId]
		,rs.[Name]

	DROP TABLE #tmpSectionResource
END