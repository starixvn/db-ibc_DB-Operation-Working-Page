
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetMessageInLast2Days] @TicketId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get ticket league detail
 DB: bodb_OWP      
      
 Revisions: 
	20221222@Mira: Refactor flow get detail - [Redmine: #181438]
*/

    BEGIN
        DECLARE @GMT8Time DATETIME= DATEADD(HOUR, 8, CONVERT(DATETIME, GETUTCDATE()));
        DECLARE @FromDateTime DATETIME= DATEDIFF(DAY, 2, @GMT8Time);
        SET NOCOUNT ON;
        SELECT DISTINCT 
               tm.CreatedDate, 
               tm.Id AS MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId, 
               tm.IsSaved,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username
        FROM TicketMessage AS tm
             LEFT JOIN [User] AS u ON u.UserId = tm.UserId
        WHERE tm.TicketId = @TicketId
              AND tm.CreatedDate >= @FromDateTime;
    END;