/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211104@Liam
Task : Update insert/remove recipient reader
DB: bodb_OWP	

Revisions:
	20211104@Liam.Pham: Adding RecipientType & GroupId - [Redmine: #162851]
*/

ALTER TABLE [dbo].[TicketMessageReader]
ADD [RecipientType]   INT NULL,
    [GroupId]   INT NULL
