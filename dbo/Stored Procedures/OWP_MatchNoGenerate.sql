-- =============================================
-- Author:		Simon Huynh
-- Create date: 20161103
-- =============================================
CREATE PROCEDURE [dbo].[OWP_MatchNoGenerate]

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Today DATE = GETDATE()
	DECLARE @Start DATETIME = GETDATE()

	DECLARE @Old XML
	DECLARE @New XML
	
	DECLARE @Duration INT
	DECLARE @OldData NVARCHAR(MAX)
	DECLARE @NewData NVARCHAR(MAX)
	
	SET @Old =
	(
		SELECT 
				OWPMatchId '@mt',
				MatchNo '@mn'
		FROM
			OWPMatch WITH(NOLOCK)
		WHERE 
			EventDate >= @Today
		FOR XML PATH('z'), ROOT('r')
	)

	CREATE TABLE #matchNo(
		OWPMatchId INT PRIMARY KEY,
		MatchNo VARCHAR(MAX)
	);
	
	-- generate major match
	WITH [matchGTM-4] AS
	(
		SELECT
			OWPMatchId,
			CONVERT(DATE,dbo.[OWP_ConvertDateGMT-4](EventDate,KickOffTime)) EventDate,
			CONVERT (TIME, KickOffTime) EventTime
		FROM
			OWPMatch WITH(NOLOCK)
	)
	INSERT INTO #matchNo(OWPMatchId,MatchNo)
	SELECT 
		ms.OWPMatchId,
		ROW_NUMBER() OVER(PARTITION BY ms.EventDate ORDER BY ms.EventTime )
	FROM 
		[matchGTM-4] ms WITH(NOLOCK)
		LEFT JOIN MinorMatch mm WITH(NOLOCK) ON mm.MinorMatchId = ms.OWPMatchId
	WHERE
		mm.MinorMatchId IS NULL
		AND ms.EventDate >= @Today

	-- generate minor match
	INSERT INTO #matchNo(OWPMatchId,MatchNo)
	SELECT 
		mm.MinorMatchId,
		m.MatchNo + mb.Alias
	FROM 
		#matchNo m WITH(NOLOCK)
		INNER JOIN MinorMatch mm WITH(NOLOCK) ON mm.ParentMatchId = m.OWPMatchId
		INNER JOIN MinorBettype mb WITH(NOLOCK) ON mb.MinorBettypeId = mm.MinorBettypeId
	WHERE
		mm.IsRepresented = 1
		
		
	UPDATE m WITH(ROWLOCK, UPDLOCK)
	SET
		MatchNo = mn.MatchNo
	FROM 
		OWPMatch m
		INNER JOIN #matchNo mn WITH(NOLOCK) ON m.OWPMatchId = mn.OWPMatchId
			
	DROP TABLE #matchNo

	SET @New =
	(
		SELECT 
				OWPMatchId '@mt',
				MatchNo '@mn'
		FROM
			OWPMatch WITH(NOLOCK)
		WHERE 
			EventDate >= @Today
		FOR XML PATH('z'), ROOT('r')
	)

	SET @Duration = DATEDIFF(MILLISECOND,@Start,GetDate())
	SET @OldData  = REPLACE(CONVERT(NVARCHAR(MAX), @Old), '" />', '"/"')	
	SET @NewData  = REPLACE(CONVERT(NVARCHAR(MAX), @New), '" />', '"/"')

	IF(ISNULL(@NewData, '') <> ISNULL(@OldData, ''))
	BEGIN
		EXEC	dbo.OWP_WriteLog
			@CreatorId	= 8,
			@SPName		= 'OWP_MatchNoGenerate',
			@LoggedDate	= @Start,
			@Duration	= @Duration,
			@ObjectId	= NULL,
			@Data		= @NewData,
			@DataOld	= @OldData	
	END
END