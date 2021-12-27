USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_GetAssigneeByPreMatchLeagueId]    Script Date: 12/13/2021 8:43:41 AM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetAssigneeByPreMatchLeagueId] @Id INT
AS

/*  
Created: 20211213@Johnny.Thai  
Task : Get Assignee
DB: bodb_OWP  
  
Revisions:  
 20211213@Johnny.Thai : Get Assignee - [Redmine: #166513]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT u.UserId as RecipientId, 
               u.Nickname, 
               u.Username
        FROM PreMatchAssignment AS p
             INNER JOIN [User] AS u ON p.UserId = u.UserId
        WHERE p.PreMatchLeagueId = @Id;
    END;