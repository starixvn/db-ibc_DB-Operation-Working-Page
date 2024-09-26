
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetTrader] @OwpMatchId INT
AS
/*
Created: 20201203@Carlos.Nguyen
Task: Get trader
DB: bodb_OWP

Revisions:
	20201203@Carlos.Nguyen: Get trader - [Redmine: #145096]
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @HandicapHDP INT = 1
		,@OverUnderOU INT = 3
		,@1H_HandicapHDP INT = 7
		,@1H_OverUnder INT = 8

	SELECT am.Bettype AS BettypeId,
		am.UserId
	FROM Assignment AS am WITH (NOLOCK)
	WHERE am.OWPMatchId= @OwpMatchId AND am.Bettype IN (@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder)
END