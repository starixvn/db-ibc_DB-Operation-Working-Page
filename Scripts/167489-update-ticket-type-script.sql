
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220113@Mira.Nguyen
Task : Update recipient type
DB: bodb_OWP	

Revisions:
	20220113@Mira.Nguyen: Update ticket recipient type - [Redmine: #167489]
*/

UPDATE [dbo].[TicketType]
  SET 
      TypeName = 'Group Chat'
WHERE TypeId = 2;