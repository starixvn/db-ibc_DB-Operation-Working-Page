
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetAllMatchIsAssigned]
AS
/*
Created: 2020110@Carlos.Nguyen
Task : Get all match is assigned
DB: bodb_OWP

Revisions:
	2020110@Carlos.Nguyen: Initial SP - [Redmine: #124448]
*/
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT ar.OWPMatchId
	FROM AutoAssignmentResult AS ar WITH (NOLOCK)
	WHERE ar.UserId IS NOT NULL
END