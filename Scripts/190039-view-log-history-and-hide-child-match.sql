
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230906@los
Task : New table
DB: bodb_OWP	

Revisions:
	20230906@los: New table [Redmine: #190039]
*/

CREATE TABLE EventPickingUpdateType(
	Id INT    NOT NULL,
	UpdateType VARCHAR(5000),
	RAndDUpdate VARCHAR(5000),
	CONSTRAINT [PK_EventPickingUpdateType_Id] PRIMARY KEY CLUSTERED ( [Id] )
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
(Id         INT IDENTITY(1, 1) NOT NULL, 
 [Date]     DATETIME NOT NULL, 
 InfositeId INT, 
 UpdateTypeId INT,
 ModifiedBy VARCHAR(5000), 
 [Action]   VARCHAR(5000) , 
 [OldValue] VARCHAR(5000), 
 [NewValue] VARCHAR(5000),
 CONSTRAINT [PK_EventPickingLog_Id] PRIMARY KEY CLUSTERED ( [Id] ASC)
);

CREATE TABLE EventPickingConfirmed
(InfositeId INT );