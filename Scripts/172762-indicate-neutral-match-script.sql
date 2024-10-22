/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220516@luca.duong
Task : add IsNeutral os_match
DB: bodb_OWP	

Revisions:
	20220516@luca.duong: add IsNeutral  to os_match - [Redmine: #172762]
*/

ALTER TABLE OSMatch 
ADD IsNeutral BIT DEFAULT(0)