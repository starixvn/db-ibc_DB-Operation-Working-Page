/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Market_GetAll]
AS	
/*
Created: 20180824@Raymond.Le
Task : Get all Market
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT [ResourceId] AS MarketId
		  ,[Value] AS MarketName
	FROM dbo.[RefResource] WITH (NOLOCK)
	WHERE RefName = 'Market'
END