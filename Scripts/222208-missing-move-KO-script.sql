
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 222208@Los
Task : Correct old/new event date when write log
DB: bodb_OWP	

Revisions:
	222208@Los: Correct old/new event date when write log - [Redmine: #222208]
*/

UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264220 AND  InfositeId=7517084;


UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264211 AND  InfositeId=7266358;


UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264212 AND  InfositeId=7266358;

UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264198 AND  InfositeId=6942624;

UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264199 AND  InfositeId=6942624;

UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264200 AND  InfositeId=6934152;

UPDATE EventPickingLog
SET OldValue= NewValue,
NewValue=OldValue
WHERE Id=3264201 AND  InfositeId=6934152;



