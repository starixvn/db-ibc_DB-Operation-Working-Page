/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250414@Los
Task : search-user-chat-script
DB: bodb_OWP	

Revisions:
	20250414@Los:search-user-chat-script - [Redmine: #223430]
*/

ALTER TABLE [User]
ADD IsNewUser BIT;