/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RefResourceGetByName]
	@RefName VARCHAR(30)
AS	
/*
Created: 2016-10-06@Aaron
Task : Get all rerources by name
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]  
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	 r.RefResourceId
			,r.ResourceId
			,r.Value
	FROM dbo.RefResource r WITH (NOLOCK)
	WHERE r.RefName = @RefName
END