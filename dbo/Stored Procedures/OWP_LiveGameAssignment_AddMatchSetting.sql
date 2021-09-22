
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMatchSetting] @OWPMatchId INT
	,@DataXml NVARCHAR(MAX) 
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190729@Kane.Le
 Task : add new MatchSetting
 DB: bodb_OWP

 Revisions:
	20190729@Kane.Le: Initial SP - [Feature: #117461]
	20190802@Kane.Le: Insert list MatchSettings - [Feature: #117461]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblMatchSetting (
		OWPMatchId INT
		,Bettype INT
		,Spread SMALLMONEY
		,Maxbet MONEY
		)

	DECLARE @idoc INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@DataXml

	INSERT INTO #tblMatchSetting (
		OWPMatchId
		,Bettype
		,Spread
		,Maxbet
		)
	SELECT @OWPMatchId
		,data.Bettype
		,data.Spread
		,data.Maxbet
	FROM OPENXML(@idoc, '/Root/Row', 1) WITH (
			Bettype INT
			,Spread SMALLMONEY
			,Maxbet MONEY
			) AS data

	EXEC sp_xml_removedocument @idoc

	INSERT INTO dbo.MatchSetting (
		OWPMatchId
		,Bettype
		,Spread
		,Maxbet
		)
	SELECT OWPMatchId
		,Bettype
		,Spread
		,Maxbet
	FROM #tblMatchSetting

	DROP TABLE #tblMatchSetting

	SELECT @ErrCode = 0
		,@ErrMsg = ''
END