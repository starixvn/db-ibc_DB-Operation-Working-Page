
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetAllMatchIsAssigned]
AS
/*
Created: 20200110@Carlos.Nguyen
Task : Get all match is assigned
DB: bodb_OWP

Revisions:
	20200110@Carlos.Nguyen: Initial SP - [Redmine: #133428]
*/
BEGIN
	SET NOCOUNT ON
	SELECT DISTINCT ar.OWPMatchId, ar.Bettype
	FROM AutoAssignmentResult AS ar WITH (NOLOCK)
END