/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetDefaultRecipientBySubTypeId] @SubTypeId INT
AS

/*      
 Created: 20230515@Johnny
 Task : Get default Recipient 
 DB: bodb_OWP      
      
 Revisions:          
	20230515@Johnny:  Initial SP - [Redmine: #186518]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @GroupType INT= 2;
        DECLARE @SectionType INT= 3;
        SELECT CASE
                   WHEN tr.RecipientType = @GroupType
                   THEN tg.GroupId
                   WHEN tr.RecipientType = @SectionType
                   THEN rr.ResourceId
                   ELSE u.UserId
               END 'recipientId',
               CASE
                   WHEN tr.RecipientType = @GroupType
                   THEN tg.GroupName
                   WHEN tr.RecipientType = @SectionType
                   THEN rr.[Value]
                   ELSE NULL
               END 'groupName', 
               u.Username 'userName', 
               u.Nickname 'nickName', 
               tr.RecipientType 'recipientType'
        FROM dbo.TicketTypeRecipient tr WITH(NOLOCK)
             LEFT JOIN dbo.TicketGroup tg WITH(NOLOCK) ON tr.RecipientId = tg.GroupId
             LEFT JOIN dbo.[User] u WITH(NOLOCK) ON tr.RecipientId = u.UserId
             LEFT JOIN dbo.RefResource rr WITH(NOLOCK) ON tr.RecipientId = rr.ResourceId
                                                          AND rr.RefName = 'Section'
        WHERE tr.SubtypeId = @SubTypeId;
    END;