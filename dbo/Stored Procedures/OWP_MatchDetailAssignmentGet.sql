
CREATE PROCEDURE [dbo].[OWP_MatchDetailAssignmentGet] @OWPMatchId INT
	,@IsLive BIT
AS
/*
 Created: 2016-10-06@John
 Task : Get new Match Detail Assignment   
 DB: bodb_OWP  

 Note:  AssignmentType 1 Assignee    
     AssignmentType 2 Other Time    
  AssignmentType 3 ET & PK    
      
 Revisions:    
	20170206@Julien	:	Fix issue missing check username on MainDB       
*/
BEGIN
	SET NOCOUNT ON

	----Match Detail Assignment      
	CREATE TABLE #Assignees (
		UserId INT
		,Assignee VARCHAR(30)
		,AssignmentType SMALLINT
		,BetType INT
		,OWPMatchId INT
		,IsLive BIT
		,Skype VARCHAR(50)
		,Extension VARCHAR(30)
		,Phone VARCHAR(30)
		,LocationCode VARCHAR(10)
		)

	CREATE TABLE #LiveAssignment (
		Bettype NVARCHAR(200)
		,Asignees NVARCHAR(2000)
		,MaxBet MONEY
		,Spread MONEY
		,IsCancelled BIT
		)

	INSERT INTO #Assignees (
		UserId
		,Assignee
		,AssignmentType
		,BetType
		,OWPMatchId
		,IsLive
		,Skype
		,Extension
		,Phone
		,LocationCode
		)
	SELECT a.UserId
		,dbo.OWP_GetUsernameByUserId(u.UserId)
		,a.AssignmentType
		,a.Bettype
		,@OWPMatchId
		,@IsLive
		,u.Skype
		,u.Extension
		,u.Phone
		,u.LocationCode
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE a.OWPMatchId = @OWPMatchId
		AND a.IsLive = @IsLive

	-- Get Spread, Maxbet from MatchSetting
	INSERT INTO #LiveAssignment (
		Bettype
		,Asignees
		,MaxBet
		,Spread
		,IsCancelled
		)
	SELECT bt.typenamee AS Bettype
		,(
			SELECT STUFF((
						SELECT ',' + a.Assignee + ':' + CONVERT(VARCHAR(100), a.UserId) + ':' + CONVERT(VARCHAR(100), a.AssignmentType)
						FROM #Assignees AS a WITH (NOLOCK)
						WHERE a.bettype = b.bettype
						ORDER BY a.AssignmentType ASC
						FOR XML PATH('')
						), 1, 1, '')
			) AS Assignees
		,(ms.Maxbet / 1000) AS Maxbet -- 10K
		,ms.Spread
		,(CASE 
			WHEN mbc.bettype IS NOT NULL THEN 1
			ELSE 0 END
			) AS IsCancelled
	FROM #Assignees AS b WITH (NOLOCK)
		INNER JOIN dbo.MatchSetting AS ms WITH (NOLOCK) ON b.Bettype = ms.Bettype
		AND ms.OWPMatchId = b.OWPMatchId
		INNER JOIN bodb02.dbo.bettype AS bt WITH (NOLOCK) ON b.bettype = bt.typeid
		LEFT JOIN dbo.MatchBetypeCancel AS mbc WITH (NOLOCK) ON mbc.OWPMatchId = ms.OWPMatchId
		AND mbc.Bettype = ms.Bettype
	GROUP BY b.bettype
		,bt.typenamee
		,ms.Spread
		,ms.Maxbet
		,mbc.bettype
		,b.OWPMatchId

	-- Get Spread, Maxbet from LeagueSetting
	DECLARE @LeagueId INT = NULL

	SELECT @LeagueId = OWPLeagueId
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	-------------------------------------------------
	INSERT INTO #LiveAssignment (
		Bettype
		,Asignees
		,MaxBet
		,Spread
		,IsCancelled
		)
	SELECT bt.typenamee AS Bettype
		,(
			SELECT STUFF((
						SELECT ',' + a.Assignee + ':' + CONVERT(VARCHAR(100), a.UserId) + ':' + CONVERT(VARCHAR(100), a.AssignmentType)
						FROM #Assignees AS a WITH (NOLOCK)
						WHERE a.bettype = b.bettype
						ORDER BY a.AssignmentType ASC
						FOR XML PATH('')
						), 1, 1, '')
			) AS Assignees
		,(
			(
				SELECT [dbo].[OWP_MaxBetGet](2, @LeagueId, b.Bettype)
				) / 1000
			) AS Maxbet -- 10K
		,(
			SELECT [dbo].[OWP_SpreadGet](2, @LeagueId, b.Bettype)
			) AS Spread
		,(CASE 
			WHEN mbc.bettype IS NOT NULL THEN 1
			ELSE 0 END
			) AS IsCancelled
	FROM #Assignees AS b WITH (NOLOCK)
		INNER JOIN bodb02.dbo.bettype AS bt WITH (NOLOCK) ON b.bettype = bt.typeid
		LEFT JOIN dbo.MatchBetypeCancel AS mbc WITH (NOLOCK) ON mbc.Bettype = b.Bettype
		AND mbc.OWPMatchId = b.OWPMatchId
	WHERE b.Bettype NOT IN (
			SELECT Bettype
			FROM dbo.MatchSetting
			WHERE OWPMatchId = @OWPMatchId
			)
	GROUP BY b.bettype
		,bt.typenamee
		,mbc.bettype
		,b.OWPMatchId

	SELECT Bettype
		,Asignees
		,MaxBet
		,Spread
		,IsCancelled
	FROM #LiveAssignment WITH (NOLOCK)

	SELECT DISTINCT a.UserId
		,a.Assignee AS Username
		,a.Skype
		,a.Extension
		,a.Phone
		,a.LocationCode
	FROM #Assignees AS a WITH (NOLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId

	DROP TABLE #LiveAssignment

	DROP TABLE #Assignees
END
/*        
GO         
 GRANT EXECUTE ON [dbo].[OWP_MatchDetailAssignmentGet] TO [bodbOWPNet]        
GO         
 GRANT VIEW DEFINITION ON [dbo].[OWP_MatchDetailAssignmentGet] TO [bodbOWPNet]        
GO        
*/