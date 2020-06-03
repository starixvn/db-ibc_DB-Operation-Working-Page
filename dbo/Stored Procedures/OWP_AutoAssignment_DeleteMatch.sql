
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_DeleteMatch]
	@MatchId INT,
	@Bettype INT
AS
/*
Created: 20200528@Carlos.Nguyen
Task : Delete match reasign
DB: bodb_OWP

Revisions:
	20200528@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	DELETE FROM AutoAssignmentResult
	WHERE OWPMatchId=@MatchId AND Bettype=@Bettype

END