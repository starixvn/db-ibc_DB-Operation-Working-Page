/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SoloMatchUpdate]
AS
/*    
 Created: 20161102@Harvey.Nguyen
 Task : Check & update if match is solo-match (only linked matches)
 DB: bodb_OWP    
    
 Revisions:
   20170420@Tim.Trinh: fix bug
   20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Start DATETIME = GETDATE()
		,@Today DATETIME = CONVERT(DATE, DATEADD(HOUR, 12, GETDATE()))

	CREATE TABLE #MajorMatch (
		owpmatchid INT
		,eventdate DATE
		,kickofftime TIME
		)

	CREATE TABLE #SoloMatch (
		owpmatchid INT
		,IsSolo BIT
		)

	INSERT INTO #MajorMatch (
		owpmatchid
		,eventdate
		,kickofftime
		)
	SELECT o.OWPMatchId
		,o.EventDate
		,o.KickOffTime
	FROM dbo.OWPMatch AS o WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON o.OWPLeagueId = league.OWPLeagueId
	WHERE league.CategoryId = 1
		AND DATEADD(dd, DATEDIFF(dd, 0, o.EventDate), CAST(o.KickOffTime AS DATETIME)) >= @Today
	ORDER BY o.OWPMatchId

	INSERT INTO #SoloMatch (
		owpmatchid
		,IsSolo
		)
	SELECT mm.owpmatchid
		,(CASE 
			WHEN COUNT(mm2.owpmatchid) <> 0 THEN 0
			ELSE 1 END
			)
	FROM #MajorMatch AS mm
		LEFT JOIN #MajorMatch AS mm2 ON mm.owpmatchid <> mm2.owpmatchid
		AND mm2.kickofftime BETWEEN DATEADD(HOUR, - 1, mm.kickofftime)
			AND DATEADD(HOUR, 1, mm.kickofftime)
		AND mm.eventdate = mm2.eventdate
	GROUP BY mm.owpmatchid

	DELETE sm
	FROM #SoloMatch AS sm
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON sm.owpmatchid = info.OWPMatchId
		AND sm.IsSolo = info.IsSoloMatch

	DECLARE @Old XML = (
			SELECT m.OWPMatchId '@mt'
				,m.IsSoloMatch '@is'
			FROM dbo.MatchInfo AS m WITH (NOLOCK)
				INNER JOIN #SoloMatch AS slm ON m.owpmatchid = slm.owpmatchid
			FOR XML PATH('z')
				,ROOT('r')
			)

	UPDATE m WITH (UPDLOCK, ROWLOCK)
	SET m.IsSoloMatch = slm.IsSolo
	FROM dbo.MatchInfo AS m
		INNER JOIN #SoloMatch AS slm ON m.owpmatchid = slm.owpmatchid

	DECLARE @New XML = (
			SELECT m.OWPMatchId '@mt'
				,m.IsSoloMatch '@is'
			FROM dbo.MatchInfo AS m WITH (NOLOCK)
				INNER JOIN #SoloMatch AS slm ON m.owpmatchid = slm.owpmatchid
			FOR XML PATH('z')
				,ROOT('r')
			)
	DECLARE @Duration INT = DATEDIFF(MILLISECOND, @Start, GetDate())
	DECLARE @OldData NVARCHAR(MAX) = REPLACE(CONVERT(NVARCHAR(MAX), @Old), '" />', '"/"')
	DECLARE @NewData NVARCHAR(MAX) = REPLACE(CONVERT(NVARCHAR(MAX), @New), '" />', '"/"')

	IF (ISNULL(@NewData, '') <> ISNULL(@OldData, ''))
	BEGIN
		EXEC dbo.OWP_WriteLog @CreatorId = 8
			,@SPName = 'OWP_SoloMatchUpdate'
			,@LoggedDate = @Start
			,@Duration = @Duration
			,@ObjectId = NULL
			,@Data = @OldData
			,@DataOld = @NewData
	END

	DROP TABLE #SoloMatch

	DROP TABLE #MajorMatch
END