
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_GetAllTVCondition]
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

	SELECT tv.OperatorType as Label,
		tv.Value
	FROM LeagueSettingTVCondition AS tv WITH (NOLOCK)
END