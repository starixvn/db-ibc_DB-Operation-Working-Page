/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
create PROCEDURE [dbo].[OWP_Provider_GetAll]
AS	
/*
Created: 20180807@Leo
Task : Get all Provider
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT t.ProviderId
		,t.ProviderName
	FROM dbo.[Provider] t WITH (NOLOCK)
END