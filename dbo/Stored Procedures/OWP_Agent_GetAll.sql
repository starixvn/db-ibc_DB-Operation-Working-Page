/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Agent_GetAll]
AS	
/*
Created: 20180807@Leo
Task : Get all Agent
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure  
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT t.AgentId
		,t.AgentName
	FROM dbo.Agent t WITH (NOLOCK)
END