/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryOtherAssignment] @EventDate  DATE, 
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
     SELECT pa.PreMatchLeagueId, 
            Username, 
            u.Nickname,
            CASE
                WHEN pa.UserId = 0
                THEN pa.AssignmentNote
                ELSE REPLACE(pa.AssignmentNote, '<username>', Username)
            END
     FROM PreMatchLeague AS pl WITH(NOLOCK)
          INNER JOIN PreMatchAssignment AS pa WITH(NOLOCK) ON pa.PreMatchLeagueId = pl.PreMatchLeagueId
          LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON pa.UserId = u.UserId
     WHERE pl.EventDate = @EventDate
           AND pl.IsDay = @IsDay
           AND pl.IsDeleted = 0
           AND IsTakeOver = @IsTakeOver
           AND Bettype = @Bettype
           AND AssignmentType = 2;