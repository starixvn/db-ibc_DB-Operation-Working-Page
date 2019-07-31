
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_AddMatchSetting] @OWPMatchId INT
	,@Bettype INT
	,@Spread SMALLMONEY
	,@Maxbet MONEY
	,@SpreadCN88 SMALLMONEY
	,@MaxbetCN88 MONEY
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(MAX) = '' OUTPUT
AS
/*
 Created: 20190729@Kane.Le
 Task : add new MatchSetting
 DB: bodb_OWP

 Revisions:
	20190729@Kane.Le: Initial SP - [Feature: #117461]
*/
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.MatchSetting (
		OWPMatchId
		,Bettype
		,Spread
		,Maxbet
		,SpreadCN88
		,MaxbetCN88
		)
	VALUES (
		@OWPMatchId
		,@Bettype
		,@Spread
		,@Maxbet
		,@SpreadCN88
		,@MaxbetCN88
		)

	SELECT @ErrCode = 0
		,@ErrMsg = ''
END