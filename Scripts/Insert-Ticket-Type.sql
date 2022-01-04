/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20210104@Johnny
Task : Add ticket status
DB: bodb_OWP	

Revisions:
    20210104@Johnny: Enhance Ticket Center - [Redmine: #165017]
*/
--Insert Ticket Type

INSERT INTO [dbo].[TicketType]
           ([TypeName])
     VALUES
           ('Ticket Support')
