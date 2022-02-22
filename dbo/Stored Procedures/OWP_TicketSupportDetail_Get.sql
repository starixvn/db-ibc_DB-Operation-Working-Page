
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketSupportDetail_Get] @TicketId INT
AS

/*      
 Created: 20211231@Johnny.Thai
 Task : Get ticket support detail
 DB: bodb_OWP      
      
 Revisions:          
	20211231@Johnny.Thai: Event ticket - [Redmine: #158037]
	20220222@Luca: Get TicketSubType - [Redmine: #168624]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT DISTINCT 
               til.[Subject], 
               ti.TicketId, 
               ti.TicketType, 
               ti.TicketStatus, 
               tt.TypeName, 
               tm.CreatedDate, 
               tm.Id AS MessageId, 
               tm.[Message], 
               tm.UserId, 
               tm.FileId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS Username,
			   tst.SubtypeId AS TicketSubTypeId,
		       tst.SubtypeName AS TicketSubTypeName
        FROM TicketIssue AS ti
             INNER JOIN TicketIssueSupport AS til WITH(NOLOCK) ON ti.TicketId = til.TicketId
             INNER JOIN TicketType AS tt WITH(NOLOCK) ON tt.TypeId = ti.TicketType
             INNER JOIN TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = ti.TicketId
             INNER JOIN [User] AS u WITH(NOLOCK) ON u.UserId = tm.UserId
			 LEFT JOIN TicketSubtype AS tst ON ti.TicketType = tst.TypeId AND ti.SubtypeId = tst.SubtypeId
        WHERE ti.TicketId = @TicketId;
    END;