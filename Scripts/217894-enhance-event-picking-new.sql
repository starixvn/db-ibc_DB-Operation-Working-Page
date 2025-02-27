/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250221@Los
Task : Event Picking New - Enhancement - Add new update type Remark2
DB: bodb_OWP

Revisions:
	20250221@Los: Event Picking New - Enhancement - [Redmine: #217894]
*/

INSERT INTO EventPickingUpDateType(Id,UpdateType,RAndDUpdate,[Group])
VALUES (53,'Update Remark2','Update Remark2','Remark2'),
(54,'Cancel Remark2','Cancel Remark2','Remark2')