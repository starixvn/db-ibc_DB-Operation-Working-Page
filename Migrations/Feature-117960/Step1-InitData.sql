/*
	Created: Leo.Vo
	Date: 20190717
	Task: [Redmine: #117960]
	DB: bodb_OWP
*/
USE bodb_OWP

UPDATE dbo.MessageTemplate
SET MsgTemplateContent = 'Was updated Team name for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
WHERE MsgTemplateCode = 'EditTeam'