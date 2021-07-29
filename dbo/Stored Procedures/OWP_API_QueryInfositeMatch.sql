
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_QueryInfositeMatch] @FromDate DATE
AS

/*
Created: 20200310@Jacob
Task : Need MatchID column to integrate with AdminSite
DB: bodb_OWP

Revisions:
	20200824@Jacob: Infosite-Link matches between two sites - [Redmine: #140195]   
	20210729@Tyler: Exclude deleted matches - [Redmine: #159009]   
*/

     SET NOCOUNT ON;
     SELECT m.InfoSiteMatchId, 
            m.AdminSiteMatchId, 
            m.EventDateTime, 
            m.LeagueName AS LeagueName, 
            m.HomeName AS HomeName, 
            m.AwayName AS AwayName
     FROM dbo.InfoSiteMatch m WITH(NOLOCK)
     WHERE m.EventDateTime >= @FromDate
           AND m.IsDeleted = 0;