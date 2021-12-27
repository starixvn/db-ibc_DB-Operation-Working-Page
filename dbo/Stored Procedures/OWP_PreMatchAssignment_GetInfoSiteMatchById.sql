USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_GetInfoSiteMatchById]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetInfoSiteMatchById] @Id INT
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get InfoSiteMatch By Ids
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get InfoSiteMatch By Ids - [Redmine: #166513]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT i.OWPAwayId, 
               i.OWPHomeId, 
               i.OWPLeagueId, 
               i.InfoSiteMatchId, 
               i.EventDateTime
        FROM InfoSiteMatch AS i
        WHERE i.InfoSiteMatchId = @Id;
    END;