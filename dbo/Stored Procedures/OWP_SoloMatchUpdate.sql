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
   20191125@Carlos.Nguyen:  Change strategy log - [Redmine: #124374]
   20191203@Carlos.Nguyen:  Update condition detect solo match - [Redmine: #124861]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Start DATETIME = GETDATE()
		,@PmYesterDay DATETIME = DATEADD(DAY, DATEDIFF(DAY, 1, GETDATE()), '12:00:00')

	CREATE TABLE #tblMajorMatch (
		id INT IDENTITY(1,1) PRIMARY KEY
		,owpmatchid INT
		,eventdatetime DATETIME
		)

	CREATE TABLE #tblSoloMatch (
		owpmatchid INT
		,isSolo BIT
		)

	INSERT INTO #tblMajorMatch (
		owpmatchid
		,eventdatetime
		)
	SELECT o.OWPMatchId
		,o.EventDateTime
	
	/* 1. Collect all major match from yesterday-->future*/
	FROM dbo.OWPMatch AS o WITH (NOLOCK)
		INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON o.OWPLeagueId = league.OWPLeagueId
	WHERE league.CategoryId = 1
		AND o.EventDateTime >= @PmYesterDay
	ORDER BY o.OWPMatchId
	
	/*2. Detect major match is solo match*/
	DECLARE @i INT =1
		,@isSolo INT =1
		,@rowMax INT
		,@matchid INT
		,@eventdatetime DATETIME
		
	SELECT @rowMax = MAX(mm.id) FROM #tblMajorMatch AS mm WITH (NOLOCK)
		
	WHILE(@i<=@rowMax)
	BEGIN
		SELECT TOP 1 @matchid=mm.owpmatchid
			,@eventdatetime=mm.eventdatetime
		FROM #tblMajorMatch AS mm WITH (NOLOCK)
		WHERE mm.id=@i
		SET @isSolo=1
		
		SELECT TOP 1 @isSolo=0
		FROM #tblMajorMatch AS mm WITH (NOLOCK)
		WHERE mm.id<>@i AND 1=CASE
							WHEN (@eventdatetime>=mm.eventdatetime AND DATEDIFF(MINUTE,mm.eventdatetime,@eventdatetime)<=120)
								OR
							 (mm.eventdatetime>=mm.eventdatetime AND DATEDIFF(MINUTE,@eventdatetime,mm.eventdatetime)<=60) THEN 1
							ELSE 0
							END
		
		INSERT INTO #tblSoloMatch(owpmatchid
			,isSolo)
		VALUES(@matchid,@isSolo)
		SET @i=@i+1
	END
	
	/*3. Add more minor match, status issolo same with main match*/
	INSERT INTO #tblSoloMatch (owpmatchid
			,isSolo)
	SELECT mm.MinorMatchId
		, sm.isSolo
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		INNER JOIN #tblSoloMatch AS sm WITH (NOLOCK)
		ON sm.owpmatchid=mm.ParentMatchId
	
	/*4. Detect match isn't solo match*/
	/*4.1 cause: before it is solo match but user can change leuage, result in it isn't solo match*/
	INSERT INTO #tblSoloMatch(
		owpmatchid
		,isSolo
		)
	SELECT om.OWPMatchId
		,0
	FROM dbo.OWPMatch AS om WITH (NOLOCK)
	WHERE om.EventDateTime>=@PmYesterDay
		AND om.OWPMatchId NOT IN (SELECT mm.owpmatchid
								FROM #tblSoloMatch AS mm WITH (NOLOCK))
	
	/*5. Delete match not change status*/
	DELETE sm
	FROM #tblSoloMatch AS sm
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON sm.owpmatchid = info.OWPMatchId
		AND sm.IsSolo = info.IsSoloMatch

	/*6. Update solomatch*/
	UPDATE m WITH (UPDLOCK, ROWLOCK)
	SET m.IsSoloMatch = slm.IsSolo
	FROM dbo.MatchInfo AS m
		INNER JOIN #tblSoloMatch AS slm ON m.owpmatchid = slm.owpmatchid
	
	/*9. Write log*/
	DECLARE @duration INT = DATEDIFF(MILLISECOND, @Start, GetDate())
	DECLARE @objectid INT
	DECLARE @olddata XML
	DECLARE @newdata XML
	DECLARE @olddatanvarchar NVARCHAR(MAX)
	DECLARE @newdatanvarchar NVARCHAR(MAX)
	
	CREATE TABLE #tblLog(
		id INT IDENTITY(1,1) PRIMARY KEY
		,owpmatchid INT
		,isSolo BIT
		)
		
	INSERT INTO #tblLog(
		owpmatchid
		,isSolo
		)
	SELECT slm.owpmatchid,
		slm.isSolo
	FROM #tblSoloMatch AS slm WITH (NOLOCK)
		
	SELECT @rowMax = MAX(mm.id) FROM #tblLog AS mm WITH (NOLOCK)
	SET @i=1
		
	WHILE(@i<=@rowMax)
	BEGIN
		SET @olddata=(
			SELECT slm.owpmatchid '@mt'
				,(CASE
					WHEN slm.isSolo=1 THEN 0
					WHEN slm.isSolo=0 THEN 1
				END)'@is'
			FROM #tblLog AS slm WITH (NOLOCK)
			WHERE slm.id=@i
			FOR XML PATH('z')
				,ROOT('r')
			)
			
		SET @newdata= (
			SELECT slm.owpmatchid '@mt'
				,slm.isSolo '@is'
			FROM #tblLog AS slm WITH (NOLOCK)
			WHERE slm.id=@i
			FOR XML PATH('z')
				,ROOT('r')
			)
		
		SELECT TOP 1 @objectid= slm.owpmatchid
		FROM #tblLog AS slm WITH (NOLOCK)
		WHERE slm.id=@i
		
		SET @olddatanvarchar= REPLACE(CONVERT(NVARCHAR(MAX), @olddata), '" />', '"/"')
		SET @newdatanvarchar= REPLACE(CONVERT(NVARCHAR(MAX), @newdata), '" />', '"/"')
		
		BEGIN
			EXEC dbo.OWP_WriteLog @CreatorId = 8
				,@SPName = 'OWP_SoloMatchUpdate'
				,@LoggedDate = @Start
				,@Duration = @duration
				,@ObjectId = @objectid
				,@Data = @newdatanvarchar
				,@DataOld = @olddatanvarchar
		END
		SET @i=@i+1
	END

	DROP TABLE #tblSoloMatch

	DROP TABLE #tblMajorMatch
	
	DROP TABLE #tblLog
	
END