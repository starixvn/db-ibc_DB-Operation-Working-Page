
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250325@Los
Task : Correct old/new event date when write log
DB: bodb_OWP	

Revisions:
	20250325@Los: Correct old/new event date when write log - [Redmine: #20250325]
*/

UPDATE EventPickingLog
SET OldValue= '03/26/2025 06:00:00',
NewValue='03/27/2025 06:00:00'
WHERE Id=3261756 AND  InfositeId=7627240;

UPDATE EventPickingLog
SET OldValue= '03/26/2025 06:00:00',
NewValue='03/27/2025 06:00:00'
WHERE Id=3261755 AND  InfositeId=7627240;

