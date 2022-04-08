/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220408@Johnny.Thai
Task : Adding 5ML match to LA Report
DB: bodb_OWP	

Revisions:
	20220408@Johnny.Thai: Adding 5ML match to LA Report - [Redmine: #171212]
*/
-- LA Report

ALTER TABLE [dbo].[LAReport]
ADD [FiveMajorLeague]   INT NULL;
