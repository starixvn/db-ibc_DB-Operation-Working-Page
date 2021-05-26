/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROC [dbo].[OWP_MessageGetByUserIdWithPaging] @UserId INT
	,@PageSize INT = 25
	,@PageNumber INT = 1
	,@Keyword NVARCHAR(250) = NULL
	,@IsWatcher BIT = NULL
AS
/*    
Created: 20190214@Kane.Le
Task : Get all messages by User ID whith paging
DB: bodb_OWP
    
Revisions:    
20190214@Kane.Le: init SP - [Redmine: #108723]
20200715@Jacob: Rewrite SP - [Redmine: #137417]
20200720@Mira: Remove totalRecord - [Redmine: #137752]
20200729@Esther: Ready to Trade Status  - [Redmine: #137751]
*/


SET @Keyword = ISNULL(@Keyword, N'');
DECLARE @FromRowNum INT= (@PageNumber - 1) * @PageSize + 1;
DECLARE @ToRowNum INT= @PageNumber * @PageSize;
SELECT RowNumber, 
       MessageId, 
       MessageContent, 
       IsViewed, 
       UserId, 
       CreatedBy, 
       CreatedDate, 
       IsImportant, 
       MessageType, 
       SystemMessageType
FROM
(
    SELECT ROW_NUMBER() OVER(
           ORDER BY mu.MessageId DESC) AS RowNumber, 
           mu.MessageId, 
           REPLACE(REPLACE(MessageContent, '<b>', ''), '</b>', '') AS MessageContent, 
           IsViewed, 
           UserId, 
           CreatedBy, 
           CreatedDate, 
           IsImportant, 
           MessageType, 
           SystemMessageType
    FROM dbo.MessageUser mu WITH(NOLOCK)
         INNER JOIN dbo.[Message] m WITH(NOLOCK) ON mu.MessageId = m.MessageId
         LEFT JOIN dbo.MessageTemplate mt WITH(NOLOCK) ON m.MessageType = mt.MsgTemplateId
    WHERE mu.UserId = @UserId
          AND (@IsWatcher IS NULL
               OR m.IsWatcher = @IsWatcher)
          AND (@Keyword = N''
               OR m.MessageContent LIKE '%' + @Keyword + '%')
) AS Paging
WHERE RowNumber BETWEEN @FromRowNum AND @ToRowNum
ORDER BY RowNumber;