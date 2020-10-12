/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200913@Jacob
Task : Sync Live Status to InfoSite
DB: bodb_OWP

Revisions:
	20200913@Jacob: Sync Live Status to InfoSite - [Redmine: #134336]
*/
IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'InfoSiteMatchIsLive'))
BEGIN
    DROP TABLE [dbo].[InfoSiteMatchIsLive]
END

ALTER TABLE InfoSiteMatch
ADD IsLive BIT;
