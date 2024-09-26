/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_GetCondition] 
	@LeagueSettingId INT
AS
/*
Created: 20200417@Tyler.Dang
Task : Get league setting condition
DB: bodb_OWP

Revisions:
   20200417@Tyler.Dang: Init Redmine: #132234
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT FullConditionDescription
	FROM dbo.[NewLeagueSetting] WITH (NOLOCK)
	WHERE @LeagueSettingId = LeagueSettingId
END