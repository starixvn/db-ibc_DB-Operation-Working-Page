/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211119@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20211119@CarlosNguyen: Enhance-auto-assignment - [Redmine: #163362]
	
*/
ALTER TABLE InfoSiteMatch
ADD OtherProvider NVARCHAR(2000),
Provider NVARCHAR(2000),
Remark NVARCHAR(2000),
IsSoloMatch BIT

DROP TABLE AutoAssignmentMatchHistory
DROP TABLE AutoAssignmentSuspenderHistory

DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetHistoryMatchToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetHistorySuspenderToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetMatchesByDate]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetMatctIsAssignedToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetRequestExtra]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistoryMatch]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistorySuspender]


