
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetNextListMessage] @MsgOfPage INT = 20, 
                                                             @TicketId  INT, 
                                                             @LastMsgId INT
AS

/*      
 Created: 20221222@Liam.Pham
 Task : get list message 
 DB: bodb_OWP      
      
 Revisions:          
	20221222@Liam.Pham: get next list message - [Redmine: #181438]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT TOP (@MsgOfPage) tm.CreatedDate, 
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
              AND tm.Id > @LastMsgId
        ORDER BY CreatedDate;
    END;