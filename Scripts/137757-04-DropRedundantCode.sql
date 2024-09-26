
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20200810@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP	

Revisions:
	20200830@Jacob: Archive plan for OWP tables - [Redmine: #137757]
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- DROP job
EXEC sp_delete_job @job_name = N'bodb_OWP - Job: Task_OWP_LSTReport_CaculateByDate' ;
EXEC sp_delete_job @job_name = N'bodb_OWP - Remove old data' ;

-- DROP redundant sp
DROP PROC OWP_LeagueRemarkSetting_Delete
DROP PROC OWP_LeagueRemarkSetting_Insert
DROP PROC OWP_LeagueRemarkSetting_Update
DROP PROC OWP_LiveDetail_ReadyTradeStatus_Get
DROP PROC owp_livedetail_gethomeawaytosendmessage
DROP PROC OWP_AssignmentUploading_DetermineMinorMatch
DROP PROC owp_assignmentuploading_insertminormatch
DROP PROC OWP_MinorMatchAutoDetermine
DROP PROC OWP_MinorSettingDetail_Insert

DROP PROC Task_OWP_CleanOrphanData
DROP PROC Task_OWP_LSTReport_CaculateByDate
DROP PROC Task_OWP_LSTReport_GetDataByDate
DROP PROC Task_OWP_CleanOldData
DROP PROC OWP_LSTReport_GetTraderAssignmentByDate


-- DROP redundant tables
DROP TABLE LeagueRemarkSetting
DROP TABLE LSTReport



