/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211119@carlos
Task : New table
DB: bodb_OWP	

Revisions:
	20211119@CarlosNguyen: Enhance-auto-assignment - [Redmine: #163362]
	20211203@LucaDuong: Add ProviderUsed Column - [Redmine: #163362]
	
*/
ALTER TABLE InfoSiteMatch
ADD OtherProvider NVARCHAR(2000),
Provider NVARCHAR(2000),
ProviderUsed NVARCHAR(2000),
Remark NVARCHAR(2000),
IsSoloMatch BIT

