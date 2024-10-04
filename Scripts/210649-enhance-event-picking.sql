/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240925@Johnny.Thai
Task : Add Remark2 column
DB: bodb_OWP	

Revisions:
	20240925@Johnny.Thai: Init - [Redmine: #210649]
*/

ALTER TABLE [dbo].[EventPicking]
ADD [Remark2] NVARCHAR(2000) NULL;