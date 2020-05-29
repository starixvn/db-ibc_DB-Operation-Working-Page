
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_FilterMatchTodayMissArrange]
	@AllMatchTodayDoc VARCHAR(MAX)
AS
/*
Created: 20200527@Carlos.Nguyen
Task : Get request new
DB: bodb_OWP

Revisions:
	20200527@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @idoc INT
	
	CREATE TABLE #tblMatch
	(
		MatchId INT,
		Bettype INT
	)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT
			,@AllMatchTodayDoc

	INSERT INTO #tblMatch
	(
		MatchId,
		Bettype
	)
	SELECT MatchId,
		Bettype
	FROM OPENXML(@idoc, '/Root/Row', 1)
		WITH (MatchId [int], Bettype [int])

	EXEC sp_xml_removedocument @idoc
	
	SELECT m.MatchId,
		m.Bettype
	FROM #tblMatch AS m WITH (NOLOCK)
		INNER JOIN AutoAssignmentResult AS r WITH (NOLOCK)
		ON r.OWPMatchId=m.MatchId AND r.Bettype=m.Bettype AND r.UserId IS NULL
	
	DROP TABLE #tblMatch
END