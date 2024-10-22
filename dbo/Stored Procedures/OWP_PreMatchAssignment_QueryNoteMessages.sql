/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryNoteMessages] @PreMatchNoteId INT
AS

/*  
Created: 20201006@Tyler.Dang  
Task : Query note messages
DB: bodb_OWP  
  
Revisions:  
	20201006@Tyler: get other assignments  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     SELECT i.PreMatchNoteId, 
            im.PreMatchNoteMessageId, 
            im.[Message], 
            DATEADD(HOUR, 12, im.CreatedDate) AS 'CreatedDate',
            CASE
                WHEN u.Nickname IS NULL
                THEN u.Username
                ELSE u.Nickname
            END AS 'Username'
     FROM dbo.[PreMatchNoteMessage] AS im WITH(NOLOCK)
          INNER JOIN dbo.[PreMatchNote] AS i WITH(NOLOCK) ON im.PreMatchNoteId = i.PreMatchNoteId
          INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON u.UserId = im.UserId
     WHERE i.PreMatchNoteId = @PreMatchNoteId
     ORDER BY CreatedDate DESC;