/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetDefaultRecipientBySubTypeIdAndName] @TicketTypeId INT, 
                                                                            @SubTypeName NVARCHAR(255)
AS

/*      
 Created: 20251107@Hank.Nguyen
 Task : Get default Recipient by sub type and name
 DB: bodb_OWP      
      
 Revisions:          
	20251107@Hank.Nguyen: Get default Recipient by sub type and name - [Redmine: #223689]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @IndividualRecipientType INT = 1;
        DECLARE @GroupRecipientType INT = 2;
        DECLARE @SectionRecipientType INT = 3;

       
        SELECT  u.UserId 'userId',
                u.Username 'userName',
               u.Nickname 'nickName'
        FROM dbo.TicketSubtype tr WITH(NOLOCK)
            INNER JOIN dbo.TicketTypeRecipient trt ON tr.SubtypeId = trt.SubtypeId and RecipientType = @IndividualRecipientType
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON trt.RecipientId = u.UserId
        WHERE tr.TypeId = @TicketTypeId AND tr.SubtypeName = @SubTypeName

        UNION ALL

        SELECT  u.UserId 'userId',
                u.Username 'userName',
                u.Nickname 'nickName'
        FROM dbo.TicketSubtype tr WITH(NOLOCK)
            INNER JOIN dbo.TicketTypeRecipient trt ON tr.SubtypeId = trt.SubtypeId and RecipientType = @GroupRecipientType
             INNER JOIN dbo.TicketGroup tg WITH(NOLOCK) ON trt.RecipientId = tg.GroupId
             INNER JOIN dbo.RecipientGroup rg ON rg.GroupId = tg.GroupId
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON rg.RecipientId = u.UserId
        WHERE tr.TypeId = @TicketTypeId AND tr.SubtypeName = @SubTypeName

        UNION ALL

        SELECT  u.UserId 'userId',
                u.Username 'userName',
                u.Nickname 'nickName'
        FROM dbo.TicketSubtype tr WITH(NOLOCK)
            INNER JOIN dbo.TicketTypeRecipient trt ON tr.SubtypeId = trt.SubtypeId and RecipientType = @SectionRecipientType
            INNER JOIN dbo.[User] u WITH(NOLOCK) ON trt.RecipientId = u.SectionId
        WHERE tr.TypeId = @TicketTypeId AND tr.SubtypeName = @SubTypeName;
    END;