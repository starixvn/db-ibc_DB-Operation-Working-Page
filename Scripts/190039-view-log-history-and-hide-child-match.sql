
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230906@los
Task : New table
DB: bodb_OWP	

Revisions:
	20230906@los: New table [Redmine: #190039]
*/

CREATE TABLE EventPickingAction(
	Id INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
	UpdateType VARCHAR(5000),
	RAndDUpdate VARCHAR(5000)
)

INSERT INTO EventPickingAction(UpdateType, RAndDUpdate)
VALUES('New match','New'),
	('KO time update','Update KO time'),
	('League name update','Update League name'),
	('Team name update','Update Team name'),
	('TV update','Update TV'),
	('TV cancelation','Cancel TV'),
	('IPTV update','Update IPTV'),
	('IPTV cancelation','Cancel IPTV'),
	('Provider update','Update Provider'),
	('Provider cancelation','Cancel Provider'),
	('Delete match','Deleted')
	
	
	CREATE TABLE EventPickingLog
(Id         INT
 PRIMARY KEY IDENTITY(1, 1) NOT NULL, 
 [Date]     DATETIME NOT NULL, 
 InfositeId INT, 
 ModifiedBy VARCHAR(5000), 
 [Action]   VARCHAR(5000), 
 [OldValue] VARCHAR(5000), 
 [NewValue] VARCHAR(5000)
);