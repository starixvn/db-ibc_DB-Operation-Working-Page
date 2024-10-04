
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetReactionIcon] @MessageIds NVARCHAR(MAX)
AS

/*      
 Created: 20240523@Johnny
 Task : Get Reaction Icon
 DB: bodb_OWP      
      
 Revisions: 
	20240523@Johnny: Init - [Redmine: #201603]
	20240725@Mira: get nickname or username - [Redmine: #201603]
	20241002@Mira: join with File Upload Old [Redmine: #211716]
*/

    BEGIN
        DECLARE @tblMessageId TABLE(Id INT NOT NULL);
        INSERT INTO @tblMessageId(Id)
               SELECT DISTINCT 
                      value
               FROM STRING_SPLIT(@MessageIds, ',');
        SELECT mi.MessageId, 
               mi.IconKey, 
               mi.CreatorId 'ReactUserId', 
               COALESCE(u.Nickname, u.Username) AS 'ReactUserName', 
               ISNULL(fu.SavedFileName, fuo.SavedFileName) 'ReactAvatarName'
        FROM @tblMessageId AS m
             INNER JOIN MessageIcon AS mi WITH(NOLOCK) ON m.Id = mi.MessageId
             LEFT JOIN [User] AS u WITH(NOLOCK) ON mi.CreatorId = u.UserId
             LEFT JOIN UserProfile AS up WITH(NOLOCK) ON up.UserId = mi.CreatorId
             LEFT JOIN FileUpload AS fu WITH(NOLOCK) ON fu.FileId = up.FileId
             LEFT JOIN FileUpload_Old AS fuo WITH(NOLOCK) ON fuo.FileId = up.FileId
                                                             AND fu.FileId IS NULL;
    END;