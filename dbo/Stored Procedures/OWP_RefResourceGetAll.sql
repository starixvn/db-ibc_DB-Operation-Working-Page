/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RefResourceGetAll]
	 
AS	
/*
Created: 20191011@Kane.Le
Task : Get all rerources
DB: bodb_OWP

Revisions:
	20191011@Kane.Le: Init SP - [Redmine: #121765]  	 
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	 r.ResourceId
			,r.Value	
			,r.RefName AS [Name]		 
	FROM dbo.RefResource r WITH (NOLOCK)
	ORDER BY r.[Order] ASC, r.Value ASC
END