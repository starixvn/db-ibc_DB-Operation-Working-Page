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
        DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
        DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');
        
        CREATE TABLE #tblInfoSiteAutoAssignmentResult (
			RequestId VARCHAR(2000) NOT NULL,
			InfoSiteMatchId INT NOT NULL,
			IsSaba BIT,
			IsFutsal BIT,
			PcCode NVARCHAR(2000),
			UserId_FTHDP INT,
			UserId_1HHDP INT,
			UserId_FTOU INT,
			UserId_1HOU INT,
			Bettype INT,
			[Group] NVARCHAR(200),
			UserId_LA INT,
			ExtraTime NVARCHAR(200),
			StatusCode INT,
			CreatedDate DATETIME
        )
        
        INSERT INTO #tblInfoSiteAutoAssignmentResult(
				Bettype, 
                ExtraTime, 
               [Group], 
               InfoSiteMatchId, 
               IsFutsal, 
               IsSaba, 
               PcCode, 
               RequestId, 
               StatusCode, 
               UserId_1HHDP, 
               UserId_1HOU, 
               UserId_FTHDP, 
               UserId_FTOU, 
               UserId_LA,
               CreatedDate
        )
        SELECT 
			   au.Bettype, 
               au.ExtraTime, 
               au.[Group], 
               au.InfoSiteMatchId, 
               au.IsFutsal, 
               au.IsSaba, 
               au.PcCode, 
               au.RequestId, 
               au.StatusCode, 
               au.UserId_1HHDP, 
               au.UserId_1HOU, 
               au.UserId_FTHDP, 
               au.UserId_FTOU, 
               au.UserId_LA,
               ar.CreatedDate
        FROM InfoSiteAutoAssignmentResult AS au WITH(NOLOCK)
			INNER JOIN InfoSiteMatch AS im WITH(NOLOCK) ON au.InfoSiteMatchId=im.InfoSiteMatchId
			INNER JOIN AutoAssignmentRequest AS ar WITH(NOLOCK) ON ar.RequestId=au.RequestId
		WHERE im.EventDateTime BETWEEN @FromDate AND @ToDate
        
        SELECT  t1.Bettype, 
               t1.ExtraTime, 
               t1.[Group], 
               t1.InfoSiteMatchId, 
               t1.IsFutsal, 
               t1.IsSaba, 
               t1.PcCode, 
               t1.RequestId, 
               t1.StatusCode, 
               t1.UserId_1HHDP, 
               t1.UserId_1HOU, 
               t1.UserId_FTHDP, 
               t1.UserId_FTOU, 
               t1.UserId_LA
        FROM (
			SELECT MAX(t.CreatedDate) AS CreatedDate, t.InfoSiteMatchId, t.Bettype
			FROM #tblInfoSiteAutoAssignmentResult AS t
			GROUP BY t.InfoSiteMatchId,t.Bettype
        )r
        INNER JOIN #tblInfoSiteAutoAssignmentResult AS t1
        ON t1.InfoSiteMatchId=r.InfoSiteMatchId
        AND t1.Bettype=r.Bettype 
        AND t1.ResponseDate=r.ResponseDate
        
        DROP TABLE #tblInfoSiteAutoAssignmentResult
    END;