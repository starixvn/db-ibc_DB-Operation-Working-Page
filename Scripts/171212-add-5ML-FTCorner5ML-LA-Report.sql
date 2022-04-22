/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220418@Johnny.Thai
Task : Adding FTCorner5ML, 5ML match to LA Report
DB: bodb_OWP	

Revisions:
	20220418@Johnny.Thai: Adding FTCorner5ML, 5ML match to LA Report - [Redmine: #171212]
*/
-- LA Report

ALTER TABLE [dbo].[LAReport]
ADD [FTCorner5ML]   INT NULL,
[FiveMajorLeague]   INT NULL;