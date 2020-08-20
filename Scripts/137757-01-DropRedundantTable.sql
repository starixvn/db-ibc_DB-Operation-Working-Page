
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200810@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP	

Revisions:
	20200810@Jacob: Archive plan for OWP tables - [Redmine: #137757]
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- DROP redundant sp
DROP PROC OWP_AssignmentUploading_Insert
DROP PROC OWP_AssignmentUploading_GetProcess
DROP PROC OWP_AssignmentUploading_Submit
DROP PROC OWP_AssignmentUploading_InsertMinorMatch
DROP PROC OWP_ValidationRule_CheckWhenUpload

DROP PROC OWP_LeagueRemarkSetting_InsertOrUpdate
DROP PROC OWP_MaxBetManagement_Get
DROP PROC OWP_LeagueOption_Get
DROP PROC OWP_LeagueOption_Insert
DROP PROC OWP_LeagueSetting_DeleteByOptionId
DROP PROC OWP_LeagueSetting_InsertOrUpdate
DROP PROC OWP_LeagueSetting_CopySetting
DROP PROC OWP_MinorSettingDetail_GetAll
DROP PROC OWP_MinorSettingDetail_Update
DROP PROC OWP_MinorSettingDetail_Reset
DROP PROC OWP_LeagueRemarkSetting_InsertOrUpdate
DROP PROC OWP_LeagueSetting_Update
DROP PROC OWP_EventAssignment_DataReport

-- DROP redundant table

DROP TABLE [AssignmentUploadingResult]
DROP TABLE [AssignmentUploadingOtherTrader]
DROP TABLE [AssignmentUploading]
DROP TABLE [AssignmentUploadingLog]

DROP TABLE EmployeeWorkingShiftNote_Old
DROP TABLE [JobFailedLog]

