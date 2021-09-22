/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210907@Liam
Task : Adding SABA 16mins match to LA Report
DB: bodb_OWP	

Revisions:
	20210907@Liam: Adding SABA 16mins match to LA Report - [Redmine: #160544]
*/
-- LA Report

ALTER TABLE [dbo].[LAReport]
ADD [ESoccer16Mins]   INT NULL;
