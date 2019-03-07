/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_GetNotificationQueue]
AS
/*    
 Created: 20190108@Leo.Vo
 Task : Get notification queue
 DB: bodb_OWP    
    
 Revisions:
	20190108@Leo.Vo: Initial SP - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #tblNotificationQueue (SessionId VARCHAR(50) NOT NULL)

	DELETE dbo.NotificationQueue WITH (ROWLOCK)
	OUTPUT deleted.Sessionid
	INTO #tblNotificationQueue(SessionId)

	SELECT SessionId
	FROM #tblNotificationQueue

	DROP TABLE #tblNotificationQueue
END