
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryIssueMessagesAfterInsert] @OWPLeagueId     INT = NULL, 
                                                                             @InfoSiteMatchId INT = NULL, 
                                                                             @ActorId         INT
AS

/*  
Created: 20200909@Tyler.Dang  
Task : Query issue messages after insert
DB: bodb_OWP  
  
Revisions:  
	20200909@Tyler: Init SP  - [Redmine: #140620]  
 	20201003@Tyler: update other assignments  - [Redmine: #142258]  
	20201020@Esther: Remove EventDate  - [Redmine: #143792]  
	20201119@Mira: is my message  - [Redmine: #145568]
*/

     SET NOCOUNT ON;
     DECLARE @issueId INT;
     SELECT @issueId = PreMatchIssueId
     FROM [dbo].[PreMatchIssue] WITH(NOLOCK)
     WHERE(OWPLeagueId = @OWPLeagueId
           OR InfoSiteMatchId = @InfoSiteMatchId);
     EXEC [dbo].[OWP_PreMatchAssignment_QueryIssueMessages] 
          @ActorId = @ActorId, 
          @PreMatchIssueId = @issueId;