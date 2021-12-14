USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetMatchIdsByDate]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetMatchIdsByDate] @EventDate DATE
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get MatchId By Date 
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get InfoSite MatchId By Date 
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tblMatchId(InfoSiteMatchId INT);
        INSERT INTO #tblMatchId(InfoSiteMatchId)
               SELECT i.InfoSiteMatchId
               FROM InfoSiteAutoAssignmentResult AS i, 
               (
                   SELECT ar.RequestId
                   FROM AutoAssignmentRequest AS ar
                   WHERE ar.CreatedDate =
                   (
                       SELECT MAX(ar.CreatedDate)
                       FROM AutoAssignmentRequest AS ar
                       WHERE ar.EventDate = @EventDate
                   )
               ) AS b
               WHERE i.RequestId = b.RequestId;
        DROP TABLE #tblMatchId;
    END;