/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_TelevisionGetAll]
AS	
/*
Created: 2016-10-06@Aaron
Task : Get all TVs
DB: bodb_OWP

Revisions:
	20180807@Leo: New structure of event assignment - [Redmine: #92868]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT t.TVId
		,t.TVCode
		,t.Color
	FROM dbo.Television t WITH (NOLOCK)
END