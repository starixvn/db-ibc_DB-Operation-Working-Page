/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210510@carlos.nguyen
Task : Add refresource 
DB: bodb_OWP

Revisions:
	20210510@carlos.nguyen: Init SP - [Redmine: #154779]  	 
*/

ALTER TABLE [User]
ADD BetTypePreferencesId INT,
	MultipleGamesId INT,
	AssignmentRemark NVARCHAR(500)
	
INSERT INTO [RefResource](RefName, ResourceId, Value, [Order])
VALUES('BetTypePreferences',1,'2',1),
('BetTypePreferences',2,'2[OP]',2),
('BetTypePreferences',3,'HDP',3),
('BetTypePreferences',4,'OU',4),
('BetTypePreferences',5,'HDP/OU',5),
('BetTypePreferences',6,'OU/HDP',6),

('MultipleGames',1,'',1),
('MultipleGames',2,'1G',2)


INSERT INTO Module
VALUES(12, 'AssignmentConfiguration')

INSERT INTO ModuleObject
VALUES(40,'AssignmentConfiguration',12)

INSERT INTO LogAction
VALUES(119,12,40, 2,'OWPAssignmentConfiguration', 'OWP_ProductAssignment_UserInfo_Update','<root><xml path="r/z" /><row item="user" alias="user" /><row item="columnName" alias="colName" /><row item="value" alias="value" /></root>')

