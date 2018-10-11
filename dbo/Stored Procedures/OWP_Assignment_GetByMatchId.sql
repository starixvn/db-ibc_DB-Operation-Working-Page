/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Assignment_GetByMatchId] @OWPMatchId int
AS	
/*
Created: 20180808@Leo
Task : get match assignment
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblAssignment (
		AssignmentId INT
		,OWPMatchId INT NOT NULL
		,Bettype INT NOT NULL
		,MinorBettypeId INT
		,DisplayName VARCHAR(50)
		,AssignmentType TINYINT
		,UserId INT
		,AssignmentNote NVARCHAR(200)
	)

	--get assignment of major bettype
	INSERT INTO #tblAssignment (
		AssignmentId
		,OWPMatchId
		,Bettype
		,DisplayName
		,AssignmentType
		,UserId
		,AssignmentNote
	)
	SELECT a.AssignmentId
		,@OWPMatchId
		,a.Bettype
		,mb.ShortName
		,a.AssignmentType
		,a.UserId
		,a.AssignmentNote
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
	INNER JOIN dbo.Assignment AS a WITH (NOLOCK)
	ON m.OWPMatchId = a.OWPMatchId
	INNER JOIN dbo.MajorBettype AS mb WITH (NOLOCK)
	ON mb.BettypeId = a.Bettype
	WHERE m.OWPMatchId = @OWPMatchId


	-- get assignment of minor bettype
	INSERT INTO #tblAssignment (
		AssignmentId
		,OWPMatchId
		,Bettype
		,MinorBettypeId
		,DisplayName
		,AssignmentType
		,UserId
		,AssignmentNote
	)
	SELECT a.AssignmentId
		,mm.MinorMatchId
		,mb.InheritedBettypeId
		,mb.ParentBettypeId
		,mb.MinorBettypeName
		,a.AssignmentType
		,a.UserId
		,a.AssignmentNote
	FROM dbo.MinorMatch AS mm WITH (NOLOCK)
	INNER JOIN dbo.OWPMatch AS m WITH (NOLOCK)
	ON m.OWPMatchId = @OWPMatchId AND m.OWPMatchId = mm.ParentMatchId
	INNER JOIN dbo.MinorBettype AS mb WITH (NOLOCK)
	ON mb.IsActive = 1
		AND mb.ParentBettypeId = mm.MinorBettypeId
	LEFT JOIN dbo.Assignment AS a WITH (NOLOCK)
	ON a.OWPMatchId = mm.MinorMatchId AND a.Bettype = mb.InheritedBettypeId
	ORDER BY mm.MinorMatchId, a.AssignmentId


	SELECT a.AssignmentId
		,a.OWPMatchId
		,a.Bettype
		,a.MinorBettypeId
		,a.DisplayName
		,a.AssignmentType
		,a.UserId
		,(CASE WHEN u.Nickname IS NOT NULL THEN u.Nickname ELSE u.Username END) AS Username
		,a.AssignmentNote
	FROM #tblAssignment AS a
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK)
	ON a.UserId = u.UserId


	DROP TABLE #tblAssignment
END