
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230209@Carlos.nguyen
Task : Add refresource
DB: bodb_OWP	

Revisions:
	20230209@Carlos.nguyen: Delete refresource - [Redmine: #183243]
*/

DELETE RefResource
WHERE RefName = 'MultipleGames';

DROP PROCEDURE [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section]

ALTER TABLE [User]
DROP COLUMN BetTypePreferencesId;