/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_MinorSettingDetail_GetAll]
AS
/*          
 Created: 20170315@Razor.Nguyen
 Task : Max Bet For Minor Bet Types
 DB: bodb_OWP          
          
 Revisions:      
    20180801@Raymond.Le: Display for new minor bettype & Combine setting X Mins - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Specific15Mins INT = - 1
		,@Specific10Mins INT = - 2
		,@AllInOne INT = - 89

	SELECT MinorSettingId
		,[Name]
	FROM dbo.MinorSetting WITH (NOLOCK)
	ORDER BY FromMaxBet DESC

	-- Hardcode combine 15mins & 10mins => X mins, not show setting All In One
	SELECT bt.MinorBettypeId
		,(CASE 
			WHEN bt.MinorBettypeId = @Specific15Mins THEN 'SPECIFIC X MINS'
			ELSE bt.MinorBettypeName END
			) AS MinorBettypeName
		,CASE 
			WHEN SUM(CASE 
						WHEN d.Spread IS NOT NULL
							OR d.MaxBet IS NOT NULL THEN 1
						ELSE 0
						END) > 0 THEN 1
			ELSE 0
			END AS SortPriority
	FROM dbo.MinorBettype bt WITH (NOLOCK)
		INNER JOIN dbo.MinorSetting ms WITH (NOLOCK) ON 1 = 1
		LEFT JOIN dbo.MinorSettingDetail d WITH (NOLOCK) ON d.MinorBettypeId = bt.MinorBettypeId
		AND d.MinorSettingId = ms.MinorSettingId
	WHERE bt.ParentBettypeId IS NULL
		AND bt.IsActive = 1
		AND bt.MinorBettypeId NOT IN (@AllInOne, @Specific10Mins)
	GROUP BY bt.MinorBettypeId
		,bt.MinorBettypeName
	ORDER BY SortPriority DESC
		,bt.MinorBettypeName

	SELECT bt.MinorBettypeId
		,ms.MinorSettingId
		,(d.Spread * 100) AS Spread
		,(d.MaxBet / 1000) AS MaxBet
	FROM dbo.MinorBettype bt WITH (NOLOCK)
		INNER JOIN dbo.MinorSetting ms WITH (NOLOCK) ON 1 = 1
		LEFT JOIN dbo.MinorSettingDetail d WITH (NOLOCK) ON d.MinorBettypeId = bt.MinorBettypeId
		AND d.MinorSettingId = ms.MinorSettingId
	WHERE bt.ParentBettypeId IS NULL
	ORDER BY ms.FromMaxBet DESC
END