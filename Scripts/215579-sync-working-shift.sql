/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241220@Tim
Task: API sync working shifts
DB: bodb_OWP

Revisions:
    20241220@Tim: add more location code - [Redmine: #215579]
*/

INSERT INTO dbo.RefResource (RefName, ResourceId, [Value], [Order])
VALUES ('LocationCode', 6, 'CSC', 0)
    ,('LocationCode', 7, 'DBS', 0)
    ,('LocationCode', 8, 'XPC', 0)