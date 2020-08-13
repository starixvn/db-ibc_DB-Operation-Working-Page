
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_InfoSiteMatchDel] @FromDate DATETIME, 
                                                     @ToDate   DATETIME
AS

/*
Created: 20200813@Jacob
Task : Info Site Synchronization service
DB: bodb_OWP

Revisions:
	20200813@Jacob: Prematch Assignment - [Redmine: #138643]
*/

     SET NOCOUNT ON;
     DELETE FROM InfoSiteMatch
     WHERE EventDateTime BETWEEN @FromDate AND @ToDate;