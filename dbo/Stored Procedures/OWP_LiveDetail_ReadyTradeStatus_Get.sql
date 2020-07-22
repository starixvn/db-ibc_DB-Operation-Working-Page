
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveDetail_ReadyTradeStatus_Get] @OWPMatchId INT,
														    @UserId INT
AS

/*
Created: 20200722@Mira.Nguyen
Task : Task List - Ready to Trade Status
DB: bodb_OWP

Revisions:
	20200722@Mira.Nguyen: TaskList Ready Status - [Redmine: #137751]
*/
BEGIN
     SET NOCOUNT ON;
	 SELECT ReadyDateTime
	 FROM [dbo].ReadyTradeStatus r
	 WHERE r.MatchId = @OWPMatchId AND r.UserId = @UserId;
END