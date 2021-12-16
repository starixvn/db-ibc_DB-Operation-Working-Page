USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetInfoSiteMatchByIdAndBetType]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetInfoSiteMatchByIdAndBetType] @XML NVARCHAR(MAX)
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get InfoSiteMatch By Ids and Bettype
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get InfoSiteMatch By Ids and Bettype - [Redmine: #166031]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        CREATE TABLE #tblBettypeById
        (InfoSiteMatchId INT, 
         Bettype         INT
        );
        INSERT INTO #tblBettypeById
        (InfoSiteMatchId, 
         Bettype
        )
        SELECT [InfoSiteMatchId], 
                [BetType]
        FROM OPENXML(@idoc, '/Root/Row', 1) WITH([InfoSiteMatchId] INT, [BetType] INT);
        EXEC sp_xml_removedocument 
             @idoc;
             
        SELECT DISTINCT i.EventDateTime,
               CASE
                   WHEN b.Bettype = -3
                   THEN i.HomeName + ' No.of Corners'
                   WHEN b.Bettype = -4
                   THEN i.HomeName + ' Next Corners'
                   ELSE i.HomeName
               END AS HomeName,
               CASE
                   WHEN b.Bettype = -3
                   THEN i.AwayName + ' No.of Corners'
                   WHEN b.Bettype = -4
                   THEN i.AwayName + ' Next Corners'
                   ELSE i.AwayName
               END AS AwayName,
               CASE
                   WHEN b.Bettype = 0
                   THEN i.LeagueName
                   ELSE i.LeagueName + ' - CORNERS'
               END AS LeagueName, 
               i.Division, 
               i.Remark, 
               i.WB, 
               i.[Round], 
               i.TV, 
               i.Channel, 
               i.IPTV, 
               i.Agent,
               i.InfoSiteMatchId, 
               i.AdminSiteMatchId, 
               i.Website1, 
               i.Website2, 
               i.Website3, 
               i.Website4,
               b.Bettype
        FROM InfoSiteMatch AS i INNER JOIN 
             #tblBettypeById AS b ON i.AdminSiteMatchId = b.InfoSiteMatchId
        DROP TABLE #tblBettypeById;
    END;