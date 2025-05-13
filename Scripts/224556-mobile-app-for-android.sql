/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250508@Los
Task: Mark user update password.
DB: bodb_OWP
Original: 

Revisions:
	20250508@Los: Mark user update password - [Redmine: #224556]
*/

ALTER TABLE [User]
ADD
    PasswordUpdateCount INT NOT NULL DEFAULT(0),
    LastPasswordChangedAt DATETIME NULL;
