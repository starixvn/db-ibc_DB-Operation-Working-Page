/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*      
 Created: 20220216@Johnny.Thai
 Task : New table
 DB: bodb_OWP      
      
 Revisions:          
	20220216@Johnny.Thai: New table TicketDeleteLog - [Redmine: #168673]
	20220224@Luca: new log action - [Redmine: #168673]
*/

CREATE TABLE TicketDeleteLog
(Id        INT IDENTITY(1, 1) PRIMARY KEY, 
 ModifiedBy    INT NOT NULL, 
 TicketId	INT NOT NULL,
 LogDate DATETIME NOT NULL
);

-- insert action delete ticket
INSERT INTO LogAction(ActionId,ModuleId,ModuleObjectId,ActionTypeId,ActionName,SPName,LogItems) VALUES(122,11,38,3,'OWPTicketCenterDeleteTicket','OWP_TicketCenter_DeleteTicket',N'<root><xml path="r/z" /><row item="TicketId" alias="tId" /><row item="TicketType" alias="tType" /><row item="CreatedDate" alias="tCreDate" /><row item="TicketStatus" alias="tStatus" /><row item="CreatorId" alias="tCreId" /><row item="OwpLeagueId" alias="OwpLeagueId" /><row item="OWPLeagueName" alias="OwpLeagueName" /><row item="OwpHomeId" alias="OwpHomeId" /><row item="HomeName" alias="HomeName" /><row item="OwpAwayId" alias="OwpAwayId" /><row item="AwayName" alias="AwayName" /><row item="Subject" alias="Subject" /><row item="InfoSiteMatchId" alias="InfoSiteMatchId" /></root>')