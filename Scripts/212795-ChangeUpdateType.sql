/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241104@Frankie.Nguyen
Task : change Update Provider to Update Other Provider and Cancel Provider to Cancel Other Provider
DB: bodb_OWP

Revisions:
    20241104@Frankie.Nguyen: Change update type - [Redmine: #212795]
*/

UPDATE [dbo].[EventPickingUpdateType]
SET 
    [UpdateType] = CASE 
                    WHEN [Id] = 9 THEN 'Update Other Provider'
                    WHEN [Id] = 10 THEN 'Cancel Other Provider'
                   END,
    [RAndDUpdate] = CASE 
                    WHEN [Id] = 9 THEN 'Update Other Provider'
                    WHEN [Id] = 10 THEN 'Cancel Other Provider'
                   END
WHERE [Id] IN (9, 10);

GO
