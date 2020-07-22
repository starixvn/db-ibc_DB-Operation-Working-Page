
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveDetail_ReadyTradeStatus_Insert] @OWPMatchId INT,
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
	 DECLARE @ReadyDateTime DATETIME = DATEADD(hh, 12, GETDATE());
	 INSERT INTO [dbo].ReadyTradeStatus(
		MatchId,
		UserId,
		ReadyDateTime
	 )
	 VALUES(
		@OWPMatchId,
		@UserId,
		@ReadyDateTime
	 )

	 SELECT @ReadyDateTime;
END