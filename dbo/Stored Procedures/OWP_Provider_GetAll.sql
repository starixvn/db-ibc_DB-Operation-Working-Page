/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Provider_GetAll]
AS	
/*
Created: 20180807@Leo
Task : Get all Provider
DB: bodb_OWP

 Revisions:
	20181009@Raymond.Le: new structure
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT t.ProviderId
		,t.ProviderName
	FROM dbo.[Provider] t WITH (NOLOCK)
END