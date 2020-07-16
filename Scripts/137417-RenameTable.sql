/*
Created: 20200716@Esther
Task : Live Game Assignment - Show Last Update Date time
DB: bodb_OWP	

Revisions:
	20200716@Esther: New structure of Live Game Assignment - [Redmine: #137417]
*/
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
exec sp_rename UploadHistory, AssignmentUploadHistory
ALTER TABLE AssignmentUploadHistory 
ADD EventDate Date NOT NULL
