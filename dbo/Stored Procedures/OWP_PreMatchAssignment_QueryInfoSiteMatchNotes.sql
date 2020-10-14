/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryInfoSiteMatchNotes] @EventDate DATE
AS

/*  
Created: 20200903@Tyler
Task : Query match Notes
DB: bodb_OWP  
  
Revisions:  
 20200903@Tyler: get notes  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     SELECT n.PreMatchNoteId, 
            x.InfoSiteMatchId,
            CASE
                WHEN nm.[Message] IS NOT NULL
                THEN 1
                ELSE 0
            END
     FROM(
         SELECT n.InfoSiteMatchId, 
                MAX(m.CreatedDate) AS 'MaxDate'
         FROM dbo.[PreMatchNote] AS n WITH(NOLOCK)
              LEFT JOIN dbo.[PreMatchNoteMessage] AS m WITH(NOLOCK) ON m.PreMatchNoteId = n.PreMatchNoteId
         WHERE n.EventDate = @EventDate
               AND n.InfoSiteMatchId IS NOT NULL
         GROUP BY n.InfoSiteMatchId) AS x
         INNER JOIN dbo.[PreMatchNote] AS n WITH(NOLOCK) ON n.InfoSiteMatchId = x.InfoSiteMatchId
         INNER JOIN dbo.[PreMatchNoteMessage] AS nm WITH(NOLOCK) ON nm.PreMatchNoteId = n.PreMatchNoteId
     WHERE nm.CreatedDate = x.MaxDate;