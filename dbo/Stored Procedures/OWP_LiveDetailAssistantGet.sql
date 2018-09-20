CREATE PROCEDURE [dbo].[OWP_LiveDetailAssistantGet] @OWPMatchId INT
AS
/*
Created: 20161031@Julien
Task : get assistant
DB: bodb_OWP

Revisions:
   20170728@Tim.Trinh: get bettype name
   20180418@leo.vo: add FM, AIO
*/
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #tblTraders (
		UserId INT
		,TraderName NVARCHAR(30)
		,Bettype INT
		,InheritedBettypeId INT
		,BettypeName VARCHAR(100)
		,AssignmentType INT
		,MinorMatchId INT
		,LinkBettypeId INT
		)

	-- Main Bet Types
	INSERT INTO #tblTraders (
		UserId
		,TraderName
		,Bettype
		,BettypeName
		,AssignmentType
		)
	SELECT a.UserId
		,dbo.[OWP_GetUsernameByUserId](a.UserId)
		,a.Bettype
		,mbt.[Name]
		,a.AssignmentType
	FROM dbo.Assignment AS a WITH (NOLOCK)
		INNER JOIN dbo.MajorBettype AS mbt WITH (NOLOCK) ON a.Bettype = mbt.BettypeId
	WHERE a.OWPMatchId = @OWPMatchId
		AND (mbt.BettypeId < 0 AND mbt.BettypeId NOT IN (-1003, -1004))
		AND a.IsLive = 1

	INSERT INTO #tblTraders (
		Bettype
		,BettypeName
		)
	SELECT DISTINCT bt.BettypeId
		,bt.[Name]
	FROM dbo.MajorBettype AS bt WITH (NOLOCK)
		LEFT JOIN #tblTraders AS t WITH (NOLOCK) ON bt.BettypeId = t.Bettype
	WHERE (bt.BettypeId < 0 AND bt.BettypeId NOT IN (-1003, -1004))
		AND t.Bettype IS NULL

	-- Minor Bet Types
	INSERT INTO #tblTraders (
		UserId
		,TraderName
		,Bettype
		,InheritedBettypeId
		,BettypeName
		,AssignmentType
		,MinorMatchId
		,LinkBettypeId
		)
	SELECT a.UserId
		,CASE 
			WHEN ISNULL(u.Nickname, '') <> '' THEN u.Nickname
			ELSE u.Username
			END
		,mb.MinorBettypeId
		,mb.InheritedBettypeId
		,mb.MinorBettypeName
		,a.AssignmentType
		,mm.MinorMatchId
		,mb.LinkBettypeId
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK) ON mm.MinorBettypeId = mb.ParentBettypeId
		LEFT JOIN dbo.Assignment AS a WITH (NOLOCK) ON mm.MinorMatchId = a.OWPMatchId
		AND mb.InheritedBettypeId = a.Bettype
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON a.UserId = u.UserId
	WHERE mm.IsRepresented = 1
		AND mm.ParentMatchId = @OWPMatchId
		AND (
			mb.InheritedBettypeId = - 1001
			OR mb.InheritedBettypeId = - 1002
			)

	--------------
	IF NOT EXISTS (
			SELECT 1
			FROM dbo.OWPMatch AS om WITH (NOLOCK)
			WHERE om.OWPMatchId = @OWPMatchId
			)
	BEGIN
		TRUNCATE TABLE #tblTraders
	END

	SELECT t.Bettype
		,t.InheritedBettypeId
		,t.BettypeName
		,t.MinorMatchId
		,t.LinkBettypeId
	FROM (
		SELECT DISTINCT t.Bettype
			,t.InheritedBettypeId
			,t.BettypeName
			,t.MinorMatchId
			,t.LinkBettypeId
		FROM #tblTraders AS t WITH (NOLOCK)
		) AS t
	ORDER BY (CASE 
			WHEN t.Bettype = - 1001 THEN 1
			WHEN t.Bettype = - 1002 THEN 2
			ELSE 3 END
			) ASC
		,t.Bettype DESC

	IF NOT EXISTS (
			SELECT 1
			FROM #tblTraders AS t WITH (NOLOCK)
			WHERE t.UserId IS NOT NULL
			)
	BEGIN
		TRUNCATE TABLE #tblTraders
	END

	SELECT t.UserId
		,t.Bettype
		,t.AssignmentType
		,(CASE 
			WHEN t.LinkBettypeId IS NOT NULL
				AND (
					t.UserId = (
						SELECT UserId
						FROM #tblTraders AS td WITH (NOLOCK)
						WHERE td.Bettype = t.LinkBettypeId
							AND t.AssignmentType = td.AssignmentType
						)
					) THEN 1
			ELSE 0 END
			) AS IsLinked
		,(CASE 
			WHEN t.LinkBettypeId IS NULL
				AND (
					t.UserId IN (
						SELECT UserId
						FROM #tblTraders AS td WITH (NOLOCK)
						WHERE td.LinkBettypeId = t.Bettype
							AND td.AssignmentType = t.AssignmentType
						)
					) THEN 1
			ELSE 0 END
			) AS IsHasChildLinked
	FROM #tblTraders AS t WITH (NOLOCK)
	WHERE t.UserId IS NOT NULL
	ORDER BY t.AssignmentType

	SELECT DISTINCT t.UserId
		,t.TraderName AS Username
		,u.Skype
		,u.Extension
		,u.Phone
		,u.LocationCode
	FROM #tblTraders AS t WITH (NOLOCK)
		LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON t.UserId = u.UserId
	WHERE t.UserId IS NOT NULL

	DROP TABLE #tblTraders
END