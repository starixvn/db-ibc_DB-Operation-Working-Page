
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241002@Mira
Task : Recover file upload data
DB: bodb_OWP	

Revisions:
	20241002@Mira: Add specify computed column for file extension [Redmine: #211716]
*/

ALTER TABLE FileUpload
ADD Extension AS RIGHT(Title, CHARINDEX('.', REVERSE(Title)) - 1) PERSISTED;

ALTER TABLE FileUpload_Old
ADD Extension AS RIGHT(Title, CHARINDEX('.', REVERSE(Title)) - 1) PERSISTED;