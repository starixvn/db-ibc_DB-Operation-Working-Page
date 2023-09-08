
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230906@los
Task : New table
DB: bodb_OWP	

Revisions:
	20230906@los: New table [Redmine: #190039]
*/

CREATE TABLE EventPickingUpdateType(
	Id INT PRIMARY KEY  NOT NULL,
	UpdateType VARCHAR(5000),
	RAndDUpdate VARCHAR(5000)
)


INSERT INTO EventPickingUpdateType(Id,UpdateType, RAndDUpdate)
VALUES(1,'New match','New'),
	(2,'KO time update','Update KO time'),
	(3,'League name update','Update League name'),
	(4, 'Team name update','Update Team name'),
	(5,'TV update','Update TV'),
	(6,'TV cancel','Cancel TV'),
	(7,'IPTV update','Update IPTV'),
	(8,'IPTV cancel','Cancel IPTV'),
	(9,'Provider update','Update Provider'),
	(10,'Provider cancel','Cancel Provider'),
	(11,'Delete match','Deleted')
	
	
CREATE TABLE EventPickingLog
(Id         INT
 PRIMARY KEY IDENTITY(1, 1) NOT NULL, 
 [Date]     DATETIME NOT NULL, 
 InfositeId INT, 
 UpdateTypeId INT,
 ModifiedBy VARCHAR(5000), 
 [Action]   VARCHAR(5000) , 
 [OldValue] VARCHAR(5000), 
 [NewValue] VARCHAR(5000)
);


CREATE TABLE EventPickingConfirmed
(InfositeId INT );