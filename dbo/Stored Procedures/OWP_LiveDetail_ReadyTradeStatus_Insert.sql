
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveDetail_ReadyTradeStatus_Insert] @OWPMatchId INT, 
                                                               @UserId     INT
AS

/*
Created: 20200722@Mira.Nguyen
Task : Task List - Ready to Trade Status
DB: bodb_OWP

Revisions:
	20200722@Mira.Nguyen: TaskList Ready Status - [Redmine: #137751]
	20200831@Tyler: Fix insert duplicate - [Redmine: #139685]
*/

     SET NOCOUNT ON;
     DECLARE @ReadyDateTime DATETIME= DATEADD(hh, 12, GETDATE());
     INSERT INTO [dbo].ReadyTradeStatus
     (MatchId, 
      UserId, 
      ReadyDateTime
     )
            SELECT @OWPMatchId, 
                   @UserId, 
                   @ReadyDateTime
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM [dbo].[ReadyTradeStatus] WITH(NOLOCK)
                WHERE MatchId = @OWPMatchId
                      AND UserId = @UserId
            );
     SELECT @ReadyDateTime;