USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetInfoSiteMatchByIds]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetInfoSiteMatchByIds] @MatchIds NVARCHAR(MAX)
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get InfoSiteMatch By Ids
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get InfoSiteMatch By Ids
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblMatchId(InfoSiteMatchId INT);
        INSERT INTO #tblMatchId(InfoSiteMatchId)
               SELECT DISTINCT 
                      val
               FROM dbo.strSplit(@MatchIds, ',');
        SELECT i.EventDateTime, 
               i.HomeName, 
               i.AwayName, 
               i.LeagueName, 
               i.Division, 
               i.Remark, 
               i.WB, 
               i.[Round], 
               i.TV, 
               i.Channel, 
               i.IPTV, 
               i.Agent,
               CASE
                   WHEN i.Provider LIKE '%WOO%'
                   THEN 'WOO'
                   WHEN i.Provider LIKE '%AL%'
                   THEN 'AL'
                   WHEN i.Provider LIKE '%SLR%'
                   THEN 'SLR'
                   ELSE NULL
               END AS ReporterPhone, 
               i.InfoSiteMatchId, 
               i.AdminSiteMatchId,
			   i.Website1,
			   i.Website2,
			   i.Website3,
			   i.Website4
        FROM InfoSiteMatch AS i, 
             #tblMatchId AS m
        WHERE i.InfoSiteMatchId = m.InfoSiteMatchId;
        DROP TABLE #tblMatchId;
    END;