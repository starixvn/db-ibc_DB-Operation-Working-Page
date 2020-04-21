/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueManagement_UpdateCondition] @ActorId INT
	,@LeagueSettingId INT
	,@HasTV BIT = 0
	,@TV NVARCHAR(50) = NULL
	,@Round NVARCHAR(200) = NULL
	,@Division NVARCHAR(200) = NULL
	,@FullConditionDescription NVARCHAR(MAX) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
Created: 20200417@Tyler.Dang
Task : update league setting condition
DB: bodb_OWP

Revisions:
   20200417@Tyler.Dang: Init Redmine: #132506
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.[NewLeagueSetting] WITH (ROWLOCK)
	SET [TV] = @TV
		,[HasTV] = @HasTV
		,[Round] = @Round
		,[Division] = @Division
		,[FullConditionDescription] = @FullConditionDescription
	WHERE LeagueSettingId = @LeagueSettingId

	SELECT @ErrCode = 0
		,@ErrMsg = 'Condition has been updated successfully!'
END