
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_API_AdminsiteIntegration_GetTrader] @MatchId INT
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
		,@LeagueCategoryId_MJ INT = 1

	SELECT am.Bettype,
		am.UserId
	FROM Assignment AS am WITH (NOLOCK)
	WHERE am.OWPMatchId= @MatchId AND am.Bettype IN (@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder)
END