
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetReactionIcon] @MessageIds NVARCHAR(MAX)
AS

/*      
 Created: 20240523@Johnny
 Task : Get Reaction Icon
 DB: bodb_OWP      
      
 Revisions: 
	20240523@Johnny: Init - [Redmine: #201603]
*/

    BEGIN
        DECLARE @tblMessageId TABLE(Id INT NOT NULL);
        INSERT INTO @tblMessageId(Id)
               SELECT val
               FROM dbo.fnc_SplitStrings(@MessageIds, ',');
        SELECT mi.MessageId, 
               mi.IconKey, 
               mi.CreatorId 'ReactUserId', 
               u.Username 'ReactUserName', 
               fu.SavedFileName 'ReactAvatarName'
        FROM @tblMessageId AS m
             INNER JOIN MessageIcon AS mi WITH(NOLOCK) ON m.Id = mi.MessageId
             LEFT JOIN [User] AS u WITH(NOLOCK) ON mi.CreatorId = u.UserId
             LEFT JOIN UserProfile AS up WITH(NOLOCK) ON up.UserId = mi.CreatorId
             LEFT JOIN FileUpload AS fu WITH(NOLOCK) ON fu.FileId = up.FileId;
    END;