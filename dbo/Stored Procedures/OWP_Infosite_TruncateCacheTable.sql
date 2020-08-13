
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Infosite_TruncateCacheTable]
AS

/*
Created: 20200813@Jacob
Task : Info Site Synchronization service
DB: bodb_OWP

Revisions:
	20200813@Jacob: Truncate cache table after restarting info site service - [Redmine: #137755]
*/

     SET NOCOUNT ON;
     
	 -- DELETE all data of cache table InfoSiteMatch
	 DELETE FROM InfoSiteMatch