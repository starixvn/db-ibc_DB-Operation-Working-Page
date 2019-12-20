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
		,SUM([Type1_FT_HDP] + [Type1_FT_OU] + [Type1_FT_HDPOU]) AS [TotalMatch]
		,SUM([Type1_FT_HDP]) AS [Type1_FT_HDP]
		,SUM([Type1_FT_OU]) AS [Type1_FT_OU]
		,SUM([Type1_FT_HDPOU]) AS [Type1_FT_HDPOU]
		,SUM([Type2_AUS_League]) AS [Type2_AUS_League]
		,SUM([Type2_AUS_League_Corner]) AS [Type2_AUS_League_Corner]
		,SUM([Type2_JAP_Divison1]) AS [Type2_JAP_Divison1]
		,SUM([Type2_JAP_Divison2]) AS [Type2_JAP_Divison2]
		,SUM([Robot3_X2]) AS [Robot3_X2]
		,SUM([Robot3_X3]) AS [Robot3_X3]
		,SUM([Robot3_X3_Plus]) AS [Robot3_X3_Plus]
		,SUM([Type3_Solo_Major]) AS [Type3_Solo_Major]
		,SUM([Type4_Major]) AS [Type4_Major]
		,SUM([Type4_Minor1]) AS [Type4_Minor1]
		,SUM([Type4_Minor2]) AS [Type4_Minor2]
		,SUM([Type4_Minor3]) AS [Type4_Minor3]
		,SUM([Type4_1ST_Major]) AS [Type4_1ST_Major]
		,SUM([Type4_1ST_Other]) AS [Type4_1ST_Other]
		,SUM([Type4_Fantasy]) AS [Type4_Fantasy]
		,SUM([Type4_Corner_NextCorner]) AS [Type4_Corner_NextCorner]
		,SUM([Type4_15M]) AS [Type4_15M]
		,SUM([Type4_10M]) AS [Type4_10M]
		,SUM([Type4_TotalBooking]) AS [Type4_TotalBooking]
		,SUM([Type4_PKSO]) AS [Type4_PKSO]
		,SUM([Type4_Winner]) AS [Type4_Winner]
		,SUM([PH_1X2_Major]) AS [PH_1X2_Major]
		,SUM([PH_1X2_Minor1]) AS [PH_1X2_Minor1]
		,SUM([PH_1X2_Minor2]) AS [PH_1X2_Minor2]
		,SUM([PH_1X2_Minor3]) AS [PH_1X2_Minor3]
		,SUM([PH_1X2_Others]) AS [PH_1X2_Others]
		,SUM([X5]) AS [X5]
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