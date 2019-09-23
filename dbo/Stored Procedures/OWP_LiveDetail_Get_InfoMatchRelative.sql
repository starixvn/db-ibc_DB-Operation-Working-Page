
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_Get_InfoMatchRelative]
	 @OWPMatchId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20190920@Carlos.Nguyen
Task : get info match relative
DB: bodb_OWP

Revisions:    
	20190920@Carlos.Nguyen: init SP - [Redmine: #120593]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE
		@TVIds NVARCHAR(500)
		,@Channel NVARCHAR(100)
		,@WB NVARCHAR(100)
		,@ProviderIds NVARCHAR(100)
		,@OtherProviderIds NVARCHAR(100)
		,@AgentIds NVARCHAR(100)
		,@Phone NVARCHAR(200)
		,@ParentMatchId INT
		,@OldOtherProviderIds NVARCHAR(100)
	
	CREATE TABLE #tblMatchIdRelative(
		MatchId INT)
	
	CREATE TABLE #tblMatchInfoRelative(
		Id INT IDENTITY
		,MatchId INT
		,TVIds NVARCHAR(500)
		,Channel NVARCHAR(100)
		,WB NVARCHAR(100)
		,ProviderIds NVARCHAR(100)
		,OtherProviderIds NVARCHAR(100)
		,AgentIds NVARCHAR(100)
		,Phone NVARCHAR(200)
		)
	/*Select minor match*/
	IF EXISTS(SELECT 1
		FROM dbo.MinorMatch AS mm WITH (NOLOCK)
		WHERE mm.MinorMatchId=@OWPMatchId)
		BEGIN
			SELECT TOP 1 @ParentMatchId=mm.ParentMatchId
			FROM dbo.MinorMatch as mm WITH (NOLOCK)
			WHERE mm.MinorMatchId=@OWPMatchId
		
			INSERT INTO #tblMatchIdRelative(MatchId)
			SELECT mm.MinorMatchId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId = @ParentMatchId
		
			INSERT INTO #tblMatchIdRelative(MatchId)
			VALUES (@ParentMatchId)
		END
	ELSE
		BEGIN
			INSERT INTO #tblMatchIdRelative(MatchId)
			SELECT mm.MinorMatchId
			FROM dbo.MinorMatch AS mm WITH (NOLOCK)
			WHERE mm.ParentMatchId=@OWPMatchId
			
			INSERT INTO #tblMatchIdRelative(MatchId)
			VALUES(@OWPMatchId)
		END
	
	INSERT INTO #tblMatchInfoRelative(MatchId,
		TVIds,
		Channel,
		WB,
		ProviderIds,
		OtherProviderIds,
		Phone)
	SELECT tblMIdr.MatchId,
	'',
		m.Channel,
		m.WB
		,''
		,''
		,m.Phone
	FROM #tblMatchIdRelative AS tblMIdr WITH (NOLOCK)
		JOIN dbo.MatchTelevision AS mtv WITH (NOLOCK)ON mtv.OWPMatchId=tblMIdr.MatchId
		JOIN dbo.MatchInfo m WITH (NOLOCK) ON mtv.OWPMatchId=m.OWPMatchId
	SELECT *
	FROM #tblMatchInfoRelative
END