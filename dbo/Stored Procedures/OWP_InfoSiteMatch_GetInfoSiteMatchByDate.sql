/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_InfoSiteMatch_GetInfoSiteMatchByDate] @EventDate DATE

/* 
 Created: 20201023@Carlos.nguyen
 Task : Event Upload - Skip change notification for match with correct InfoSite ID
 DB: bodb_OWP    
    
 Revisions:
	20201023@Carlos.nguyen: Initial SP - [Redmine: #142320]
	20201109@Carlos.Nguyen: LA Auto Assignment - Determine ET/PK match - [Redmine: #144570]
	20200128@Mira: Saba match validation rule - [Redmine: 149472]
*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00'), @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        SELECT i.InfoSiteMatchId, 
               i.LeagueName, 
               i.HomeName, 
               i.AwayName,
			   i.EventDateTime,
               i.[Round], 
               i.Division, 
               i.Agent, 
               i.TV, 
               i.Channel, 
               i.WB, 
               i.Website1, 
               i.Website2, 
               i.Website3, 
               i.Website4, 
               i.IPTV, 
               i.IsNeutral, 
               i.AdminSiteMatchId, 
               i.ETPK AS EtPk
        FROM InfoSiteMatch AS i WITH(NOLOCK)
        WHERE i.EventDateTime BETWEEN @FromDate AND @ToDate;
    END;