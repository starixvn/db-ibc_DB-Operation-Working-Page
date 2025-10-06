/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251002@Los
Task : Rebuild remark2
DB: bodb_OWP

Revisions:
	20251002@Los: Rebuild remark2 - [Redmine: #240366]
*/

/*UPDATE LeagueManagementSetting
SET Remark2 = ISNULL(Remark2, '') + ISNULL(Remark2WD, '') + ISNULL(Remark2WK, '')*/

UPDATE LeagueManagementSetting
SET Remark2= 'EXPT_HDP drop 1 lv MB.(WD): SL 50K Max.'
WHERE Id=2268;

UPDATE LeagueManagementSetting
SET Remark2= 'HDP drop 1 lv MB, (Provider TV Feed Second accept 30s, Disable Auto Accept, Tick TV feed)_(WK) : Non SL Max 10K'
WHERE Id=2299;

ALTER TABLE LeagueManagementSetting
DROP COLUMN Remark2WK, Remark2WD
