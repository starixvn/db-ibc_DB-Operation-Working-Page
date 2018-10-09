/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_MatchStatus_GetByMatchId] @OWPMatchId INT
AS
/*  
 Created: Raymond.Le@20180813
 Task : Get match status list by OWP match Id
 DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @MatchStatus NVARCHAR(15)
		-- Match Status
		,@str_Live NVARCHAR(15) = 'Live'
		,@str_Inplay NVARCHAR(15) = 'In-play'
		,@str_Completed NVARCHAR(15) = 'Completed'
		,@str_Cancel NVARCHAR(15) = 'Cancel'
		,@str_Postponed NVARCHAR(15) = 'Postponed'
		,@str_Suspended NVARCHAR(15) = 'Suspended'

	CREATE TABLE #tblMatchStatusList (
		DisplayText NVARCHAR(15),
		Value NVARCHAR(15),
		IsDisplay BIT,
		IsSelected BIT
	)

	SELECT @MatchStatus = [dbo].[OWP_GetCurrentMatchStatus] (om.EventDate, om.KickOffTime, mi.MatchStatus)
	FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS om WITH (NOLOCK) ON om.OWPMatchId = @OWPMatchId
	WHERE mi.OWPMatchId = @OWPMatchId

	INSERT INTO #tblMatchStatusList (DisplayText, Value, IsSelected) 
	VALUES 	(@str_Inplay, '', 0),
			(@str_Completed, '', 0),
			(@str_Live, @str_Live, 0),
			(@str_Cancel, @str_Cancel, 0),
			(@str_Postponed, @str_Postponed, 0),
			(@str_Suspended, @str_Suspended, 0)

	--- GET list match status to display
	UPDATE #tblMatchStatusList
	SET IsSelected = 1
	WHERE DisplayText = @MatchStatus
		
	IF (@MatchStatus IN (@str_Live, @str_Cancel, @str_Postponed, @str_Suspended))
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END
	ELSE IF (@MatchStatus = @str_Inplay)
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Inplay, @str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END
	ELSE IF (@MatchStatus = @str_Completed)
	BEGIN
		UPDATE #tblMatchStatusList
		SET IsDisplay = 1
		WHERE DisplayText IN (@str_Completed, @str_Live, @str_Cancel, @str_Postponed, @str_Suspended)
	END

	SELECT ms.Value
		,ms.DisplayText
		,ms.IsSelected
	FROM #tblMatchStatusList AS ms WITH (NOLOCK)
	WHERE ms.IsDisplay = 1

	DROP TABLE #tblMatchStatusList

END