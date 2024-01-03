/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20231225@Johnny
Task : New table
DB: bodb_OWP	

Revisions:
	20231225@Johnny: Insert value [Redmine: #198108]
*/


INSERT INTO EventPickingUpdateType(Id,UpdateType, RAndDUpdate)
VALUES
	(12,'Update Round','Update Round'),
	(13,'Cancel Round','Cancel Round'),
	(14,'Update Round (H-A/T)','Update Round (H-A/T)'),
	(15,'Cancel Round (H-A/T)','Cancel Round (H-A/T)'),
	(16,'Update Remark','Update Remark'),
	(17,'Cancel Remark','Cancel Remark'),
	(18,'Update Home Remark','Update Home Remark'),
	(19,'Cancel Home Remark','Cancel Home Remark'),
	(20,'Update Away Remark','Update Away Remark'),
	(21,'Cancel Away Remark','Cancel Away Remark'),
	(22,'Update Division','Update Division'),
	(23,'Cancel Division','Cancel Division')