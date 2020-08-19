
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteOldData_Message] @FromDate DATETIME = '2020-01-03', 
                                                  @ToDate   DATETIME = '2020-01-05'
AS

/*    
 Created: 20200817@Mira
 Task : Delete old data
 DB: bodb_OWP    
    
 Revisions:
	20200817@Mira: Archive plan for OWP tables - [Redmine: #137757]	
*/

     SET NOCOUNT ON;
	 DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @FromDate), '12:00:00');
     DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @ToDate), '12:00:00');

     -- Temp table
     CREATE TABLE #tmpMessageId
     (MessageId INT
     );
     INSERT INTO #tmpMessageId
            SELECT MessageId
            FROM dbo.Message
            WHERE CreatedDate BETWEEN @FromDateTime AND @ToDateTime;

     -- DELETE MessageUser
     DELETE m
     FROM dbo.MessageUser m
          INNER JOIN #tmpMessageId t ON m.MessageId = t.MessageId;

     -- DELETE Message
     DELETE m
     FROM dbo.Message m
          INNER JOIN #tmpMessageId t ON m.MessageId = t.MessageId;

     -- DROP Temp Table
     DROP TABLE #tmpMessageId;