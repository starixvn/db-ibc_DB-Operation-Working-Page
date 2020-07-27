
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistoryMatch]
	@MatchHistoryDoc NVARCHAR(MAX)
AS
/*
Created: 20200528@Carlos.Nguyen
Task : Write history match
DB: bodb_OWP

Revisions:
	20200528@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	DELETE AutoAssignmentMatchHistory
	
	DECLARE @idoc INT
	
	EXEC sp_xml_preparedocument @idoc OUTPUT
			,@MatchHistoryDoc

		INSERT INTO dbo.AutoAssignmentMatchHistory
		(
			MatchId,
			Bettype,
			KOTime,
			OtherTime,
			Venue,
			RequireChinese,
			MaxBet
		)
		SELECT MatchId,
			Bettype,
			KOTime,
			OtherTime,
			Venue,
			RequireChinese,
			MaxBet
		FROM OPENXML(@idoc, '/Root/Row', 1)
			WITH (MatchId [int], Bettype [int], KOTime [DATETIME], OtherTime VARCHAR(100), Venue NVARCHAR(100), RequireChinese [BIT], MaxBet [MONEY])

		EXEC sp_xml_removedocument @idoc
END