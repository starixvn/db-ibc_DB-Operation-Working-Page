
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
VALUES
    (1,'New match','New'),
	(2,'Update KO time','Update KO time'),
	(3,'Update League name','Update League name'),
	(4,'Update Team name','Update Team name'),
	(5,'Update TV','Update TV'),
	(6,'Cancel TV','Cancel TV'),
	(7,'Update IPTV','Update IPTV'),
	(8,'Cancel IPTV','Cancel IPTV'),
	(9,'Update Provider','Update Provider'),
	(10,'Cancel Provider','Cancel Provider'),
	(11,'Deleted match','Deleted')
	
	
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