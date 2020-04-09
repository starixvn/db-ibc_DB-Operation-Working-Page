
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueSetting_UpdateTVCondition]
	@UpdateTvListXml NVARCHAR(MAX)
AS
/*
Created: 20200408@Tyler.Dang
Task : Update TVlist
DB: bodb_OWP
  
Revisions:
	20200408@Tyler.Dang: Init [Redmine: #131923]
	
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT

	DELETE FROM LeagueSettingTVCondition

	EXEC sp_xml_preparedocument @idoc OUTPUT
			,@UpdateTvListXml

		INSERT INTO LeagueSettingTVCondition (
				OperatorType,
				Value
			)
		SELECT [ResourceId]
			,[Value]
		FROM OPENXML(@idoc, '/Root/TVList', 1) WITH ([ResourceId] int, [Value] nvarchar(50))

		EXEC sp_xml_removedocument @idoc
END