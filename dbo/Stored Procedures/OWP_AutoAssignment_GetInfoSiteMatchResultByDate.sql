USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_GetInfoSiteMatchResultByDate]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetInfoSiteMatchResultByDate] @EventDate DATE
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get MatchId By Date 
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get InfoSite MatchId By Date - [Redmine: #166030]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @RequestIdLatestByEventDate AS VARCHAR(50);
        SET @RequestIdLatestByEventDate =
        (
            SELECT TOP 1 ar.RequestId
            FROM AutoAssignmentRequest AS ar
            WHERE ar.EventDate = @EventDate
                  AND ar.[Status] = 0
            ORDER BY ar.CreatedDate DESC
        );
        SELECT i.Bettype, 
               i.ExtraTime, 
               i.[Group], 
               i.InfoSiteMatchId, 
               i.IsFutsal, 
               i.IsSaba, 
               i.PcCode, 
               i.RequestId, 
               i.StatusCode, 
               i.UserId_1HHDP, 
               i.UserId_1HOU, 
               i.UserId_FTHDP, 
               i.UserId_FTOU, 
               i.UserId_LA
        FROM InfoSiteAutoAssignmentResult AS i
        WHERE i.RequestId = @RequestIdLatestByEventDate;
    END;