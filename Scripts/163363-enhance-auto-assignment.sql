/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211119@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20211119@CarlosNguyen: Enhance-auto-assignment - [Redmine: #163362]
	20211214@Liam.Pham: add column ProviderTV - [Redmine: #163362]
	20211217@Liam.Pham: add table AutoAssignmentHistory - [Redmine: #163362]
	
*/
ALTER TABLE InfoSiteMatch
ADD OtherProvider NVARCHAR(2000),
Provider NVARCHAR(2000),
Remark NVARCHAR(2000),
IsSoloMatch BIT,
ProviderTV NVARCHAR(200)

DROP TABLE AutoAssignmentMatchHistory
DROP TABLE AutoAssignmentSuspenderHistory

DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetHistoryMatchToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetHistorySuspenderToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetMatchesByDate]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetMatctIsAssignedToday]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_GetRequestExtra]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistoryMatch]
DROP PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistorySuspender]

CREATE TABLE InfoSiteAutoAssignmentResult(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	RequestId VARCHAR(2000) NOT NULL,
	InfoSiteMatchId INT NOT NULL,
	IsSaba BIT,
	IsFutsal BIT,
	PcCode NVARCHAR(2000),
	UserId_FTHDP INT,
	UserId_1HHDP INT,
	UserId_FTOU INT,
	UserId_1HOU INT,
	Bettype INT,
	[Group] NVARCHAR(200),
	UserId_LA INT,
	ExtraTime NVARCHAR(200),
	StatusCode INT
)

CREATE TABLE AutoAssignmentHistory
(Id                INT IDENTITY(1, 1) PRIMARY KEY, 
 RequestId         NVARCHAR(2000) NOT NULL, 
 InfoSiteMatchId   INT NOT NULL, 
 LeagueSettingId   INT, 
 MaxBetFTHDP       MONEY, 
 Maxbet_NextCorner MONEY, 
 Maxbet_NoOfCorner MONEY, 
 Provider          NVARCHAR(2000), 
 OtherProvider     NVARCHAR(2000), 
 ProviderTV        NVARCHAR(200),
);