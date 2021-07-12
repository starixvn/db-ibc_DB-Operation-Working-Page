
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20210712@Tyler
Task : Alter OS maxbet
DB: bodb_OWP	

Revisions:
	20210712@Tyler: Initial - [Redmine: #156929]
*/

ALTER TABLE dbo.OSMaxbet ALTER COLUMN MaxBet MONEY NULL;
ALTER TABLE dbo.OSMaxbet
ADD Spread MONEY NULL;
GO