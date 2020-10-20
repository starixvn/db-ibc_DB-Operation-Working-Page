/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryMainAssignment] @EventDate  DATE, 
                                                                   @IsDay      BIT, 
                                                                   @Bettype    INT, 
                                                                   @IsTakeOver BIT
AS

/*  
Created: 20201001@Tyler  
Task : Query PreMatch other assignments
DB: bodb_OWP  
  
Revisions:  
 20201001@Tyler: Init  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;

     ---- insert usernames
     SELECT pa.PreMatchLeagueId, 
            u.Username, 
            u.Nickname
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = @IsDay
           AND pl.IsDeleted = 0
           AND pa.AssignmentType = 1
           AND pa.Bettype = @Bettype
           AND pa.IsTakeOver = @IsTakeOver;