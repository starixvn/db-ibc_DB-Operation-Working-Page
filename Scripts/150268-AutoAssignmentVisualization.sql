
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20201224@Mira
Task : Auto LA - Results verification
DB: bodb_OWP	

Revisions:
	20201224@Mira: Initial - [Redmine: #150268]
*/

-- AutoAssignmentResult
ALTER TABLE dbo.AutoAssignmentResult
ADD GroupName VARCHAR(100) NULL, 
    ExtraTime VARCHAR(20) NULL;
GO