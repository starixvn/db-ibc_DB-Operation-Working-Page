USE [bodb_OWP];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchNotification_QueryLeagueAssigneeByOWPLeagueIds] @OWPLeagueIds NVARCHAR(MAX)
AS

/*  
Created: 20210615@Tyler.Dang  
Task :PreMatch notification
DB: bodb_OWP  
  
Revisions:  
 20210615@Tyler.Dang: query league assignees  - [Redmine: #156321]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempOWPLeagueId TABLE(OWPLeagueId INT);
        INSERT INTO @tempOWPLeagueId
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@OWPLeagueIds, ',') u OPTION(MAXRECURSION 0);

        -- select assignee
        SELECT DISTINCT 
               pa.PreMatchLeagueId, 
			   pl.OWPLeagueId,
               u.UserId AS AssigneeId, 
               u.Username AS AssigneeName
        FROM [dbo].PreMatchAssignment AS pa WITH(NOLOCK)
             INNER JOIN dbo.[PreMatchLeague] pl WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
             INNER JOIN @tempOWPLeagueId t ON t.OWPLeagueId = pl.OWPLeagueId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = pa.UserId;
    END;