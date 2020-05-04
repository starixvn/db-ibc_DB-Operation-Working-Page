
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetLA] @EventDate DATE
AS
/*
Created: @Carlos.Nguyen
Task : Get data LA for report
DB: bodb_OWP

Revisions:
	20191004@Carlos.Nguyen: Initial SP - [Redmine: #121452]
	20200427@Carlos.Nguyen: Update param [Redmine: #133428]
*/
BEGIN
	SET NOCOUNT ON
	CREATE TABLE #tblRequest(
		RequestId VARCHAR(500),
		OWPMatchId INT,
		UserId INT,
		Bettype INT
	)
	INSERT INTO #tblRequest(
		RequestId,
		OWPMatchId,
		UserId,
		Bettype
		)
	SELECT DISTINCT
		aur.RequestId,
		au.OWPMatchId,
		au.UserId,
		au.Bettype
	FROM dbo.AutoAssignmentResult AS au WITH(NOLOCK)
	INNER JOIN dbo.AutoAssignmentRequest AS aur WITH (NOLOCK)
	ON aur.EventDate=@EventDate AND aur.ResponseDate IS NOT NULL
	
	SELECT DISTINCT ISNULL(m.MinorMatchId, au.OWPMatchId) AS OWPMatchId
		,u.Username
	FROM #tblRequest AS au WITH(NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON au.UserId = u.UserId
	LEFT JOIN dbo.MinorMatch AS m WITH (NOLOCK) On m.ParentMatchId = au.OWPMatchId AND m.MinorBettypeId = au.Bettype
	
	SELECT * FROM  #tblRequest
	DROP TABLE #tblRequest
END