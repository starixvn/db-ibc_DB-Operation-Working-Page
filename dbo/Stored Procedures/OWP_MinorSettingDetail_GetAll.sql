CREATE PROCEDURE [dbo].[OWP_MinorSettingDetail_GetAll]
AS
/*          
 Created: 20170315@Razor.Nguyen
 Task : Max Bet For Minor Bet Types
 DB: bodb_OWP          
          
 Revisions:      
         
*/
BEGIN
	SET NOCOUNT ON

	SELECT MinorSettingId
		,[Name]
	FROM dbo.MinorSetting WITH (NOLOCK)
	ORDER BY FromMaxBet DESC

	SELECT bt.MinorBettypeId
		,bt.MinorBettypeName
		,CASE WHEN SUM(CASE WHEN Spread IS NOT NULL OR MaxBet IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS SortPriority
	FROM dbo.MinorBettype bt WITH (NOLOCK)
		INNER JOIN dbo.MinorSetting ms WITH (NOLOCK) ON 1 = 1
		LEFT JOIN dbo.MinorSettingDetail d WITH (NOLOCK) ON d.MinorBettypeId = bt.MinorBettypeId
		AND d.MinorSettingId = ms.MinorSettingId
	WHERE bt.ParentBettypeId IS NULL
	GROUP BY bt.MinorBettypeId
		,bt.MinorBettypeName
	ORDER BY SortPriority DESC, bt.MinorBettypeName

	SELECT bt.MinorBettypeId
		,ms.MinorSettingId
		,(d.Spread*100) AS Spread
		,(d.MaxBet/1000) As MaxBet 
	FROM dbo.MinorBettype bt WITH (NOLOCK)
		INNER JOIN dbo.MinorSetting ms WITH (NOLOCK) ON 1 = 1
		LEFT JOIN dbo.MinorSettingDetail d WITH (NOLOCK) ON d.MinorBettypeId = bt.MinorBettypeId
		AND d.MinorSettingId = ms.MinorSettingId
	WHERE bt.ParentBettypeId IS NULL
	ORDER BY ms.FromMaxBet DESC
END