/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
create PROCEDURE [dbo].[OWP_OtherProvider_GetAll]
AS	
/*
Created: 20180807@Leo
Task : Get all Other Provider
DB: bodb_OWP

 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT t.OtherProviderId
		,t.OtherProviderName
	FROM dbo.[OtherProvider] t WITH (NOLOCK)
END