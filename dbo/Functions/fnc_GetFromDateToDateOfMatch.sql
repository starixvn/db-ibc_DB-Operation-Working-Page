/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetFromDateToDateOfMatch] (@OWPMatchId INT)
RETURNS @DateOfMatch TABLE (
	FromDateTime DATETIME NOT NULL
	,ToDateTime DATETIME NOT NULL
	)
AS
/*
Created: 20191021@Kane.Le
Task : get fromDate, toDate of Match
DB: bodb_OWP

Param's Explanation:

Revisions:
	20191021@Kane.Le: Init SP - [Redmine: #121765]
	 
*/
BEGIN
	DECLARE @KickOffTime TIME
		,@EventDate DATE
		,@EventDateTime DATETIME

	SELECT @KickOffTime = KickOffTime
		,@EventDate = EventDate
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	IF (@KickOffTime < '12:00')
		SELECT @EventDate = DATEADD(DAY, -1, @EventDate)

	DECLARE @FromDateTime DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00')
		,@ToDateTime DATETIME = DATEADD(DAY, DATEDIFF(DAY, - 1, @EventDate), '11:59:59');

	INSERT INTO @DateOfMatch (
		FromDateTime
		,ToDateTime
		)
	VALUES (
		@FromDateTime
		,@ToDateTime
		)

	RETURN
END