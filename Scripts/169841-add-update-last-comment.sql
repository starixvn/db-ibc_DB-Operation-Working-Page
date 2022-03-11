
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20221103@Johnny
Task : Add LastComment
DB: bodb_OWP	

Revisions:
	20221103@Johnny: Init script - [Redmine: #168468]
*/

-- add LastComment
ALTER TABLE dbo.TicketIssue
ADD LastComment DATETIME NULL;
GO

-- update LastComment table TicketIssue
CREATE TABLE #tblLastComment
(TicketId    INT, 
 LastComment DATETIME
);
INSERT INTO #tblLastComment
(TicketId, 
 LastComment
)
       SELECT TicketId, 
              MAX(CreatedDate) AS LastComment
       FROM TicketMessage
       GROUP BY TicketId;
UPDATE TicketIssue
  SET 
      LastComment = lc.LastComment
FROM TicketIssue AS ti
     INNER JOIN #tblLastComment AS lc ON ti.TicketId = lc.TicketId;