/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryLeagueNotes] @EventDate DATE
AS

/*  
Created: 20200903@Tyler
Task : Query league Notes
DB: bodb_OWP  
  
Revisions:  
 20200903@Tyler: get notes  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     SELECT n.PreMatchNoteId, 
            x.OWPLeagueId,
            CASE
                WHEN nm.[Message] IS NOT NULL
                THEN 1
                ELSE 0
            END
     FROM
     (
         SELECT n.OWPLeagueId, 
                MAX(m.CreatedDate) AS 'MaxDate'
         FROM dbo.[PreMatchNote] AS n WITH(NOLOCK)
              LEFT JOIN dbo.[PreMatchNoteMessage] AS m WITH(NOLOCK) ON m.PreMatchNoteId = n.PreMatchNoteId
         WHERE n.EventDate = @EventDate
               AND n.OWPLeagueId IS NOT NULL
         GROUP BY n.OWPLeagueId
     ) AS x
     INNER JOIN dbo.[PreMatchNote] AS n WITH(NOLOCK) ON n.OWPLeagueId = x.OWPLeagueId
     INNER JOIN dbo.[PreMatchNoteMessage] AS nm WITH(NOLOCK) ON nm.PreMatchNoteId = n.PreMatchNoteId
     WHERE nm.CreatedDate = x.MaxDate;