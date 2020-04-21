/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_Delete]  @ActorId INT
	,@LeagueSettingId INT
AS
/*
Created: 20200414@Tyler.Dang
Task : Delete league setting
DB: bodb_OWP

Revisions:
   20200414@Tyler.Dang: Init Redmine: #132506
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM dbo.[NewLeagueSetting]
    WHERE LeagueSettingId = @LeagueSettingId
END