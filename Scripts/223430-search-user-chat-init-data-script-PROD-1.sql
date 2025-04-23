/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250414@Los
Task : search-user-chat-script
DB: bodb_OWP	

Revisions:
	20250414@Los:search-user-chat-script - [Redmine: #223430]
*/

CREATE TABLE #tmpOWPChatMap
(OwpUserId  INT, 
 ChatUserId CHAR(50)
);

INSERT INTO #tmpOWPChatMap
(OwpUserId, 
 ChatUserId
)
VALUES
(179348092,'Yr8M84BKwjYpvkjJp'),
(204738733,'NuGcpWBhACsXXcADt'),
(226913633,'6zXpgbqueRr8g7Hmy'),
(227382529,'aooLP7LSbzoaB2xi4'),
(227400740,'abNgwfXDquMFF98gB'),
(227945698,'qtSuy8dhWyuWFyPCM')

UPDATE u
  SET 
      u.ChatUserId = c.ChatUserId
FROM [User] AS u WITH(NOLOCK)
     INNER JOIN #tmpOWPChatMap AS c WITH(NOLOCK) ON u.UserId = c.OwpUserId;