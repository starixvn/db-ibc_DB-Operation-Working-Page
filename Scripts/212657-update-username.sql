/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241024@Tim.Trinh
Task : update username
DB: bodb_OWP

Revisions:
    20241024@Tim.Trinh: update username - [Redmine: #212657]
*/

UPDATE u
SET u.username = c.username
FROM dbo.[user] AS u WITH (ROWLOCK, UPDLOCK)
    INNER JOIN bodb02.dbo.custInfo AS c WITH (NOLOCK) ON c.custid = u.userid
WHERE c.username = 'B2CSomaly'