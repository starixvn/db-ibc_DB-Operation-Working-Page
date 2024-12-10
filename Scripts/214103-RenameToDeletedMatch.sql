/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241128@Frankie
Task :  Rename update type from "Deleted" to "Deleted Match"
DB: bodb_OWP

Revisions:
    20241128@Frankie:  Rename update type from "Deleted" to "Deleted Match" - [Redmine: #214103]
*/

UPDATE [dbo].[EventPickingUpdateType]
SET [RAndDUpdate] = 'Deleted Match', [UpdateType] = 'Deleted Match'
WHERE [Id] = 11;

GO
