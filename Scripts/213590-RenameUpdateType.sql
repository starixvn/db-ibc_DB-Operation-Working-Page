/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241114@Frankie
Task :  Rename update type from "New" to "New Match"
DB: bodb_OWP

Revisions:
    20241114@Frankie:  Rename update type from "New" to "New Match" - [Redmine: #213590]
*/

UPDATE [dbo].[EventPickingUpdateType]
SET [RAndDUpdate] = 'New Match'
WHERE [Id] = 1;

GO
