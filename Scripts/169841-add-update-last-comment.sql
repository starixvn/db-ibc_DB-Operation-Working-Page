
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20221103@Johnny
Task : Add LastComment
DB: bodb_OWP	

Revisions:
	20221103@Johnny: Init script - [Redmine: #168468]
*/

-- add LastComment
ALTER TABLE dbo.TicketIssue
ADD LastCommentDate DATETIME NULL;
GO

-- update LastComment table TicketIssue
CREATE TABLE #tblLastComment
(TicketId    INT, 
 LastCommentDate DATETIME
);
INSERT INTO #tblLastComment
(TicketId, 
 LastCommentDate
)
       SELECT TicketId, 
              MAX(CreatedDate) AS LastComment
       FROM TicketMessage
       GROUP BY TicketId;
UPDATE TicketIssue
  SET 
      LastCommentDate = lc.LastCommentDate
FROM TicketIssue AS ti
     INNER JOIN #tblLastComment AS lc WITH(NOLOCK) ON ti.TicketId = lc.TicketId;