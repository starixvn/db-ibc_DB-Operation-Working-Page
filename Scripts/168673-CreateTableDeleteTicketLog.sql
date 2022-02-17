/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*      
 Created: 20220216@Johnny.Thai
 Task : New table
 DB: bodb_OWP      
      
 Revisions:          
	20220216@Johnny.Thai: New table TicketDeleteLog - [Redmine: #168673]
*/

CREATE TABLE TicketDeleteLog
(Id        INT IDENTITY(1, 1) PRIMARY KEY, 
 UserId    INT NOT NULL, 
 TicketId	INT NOT NULL,
 EventDate DATETIME NOT NULL
);
