/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250217@Frankie
Task : Event Picking New - Enhancement
DB: bodb_OWP

Revisions:
	20250217@Frankie: Add column 'Group' table EventPickingUpdateType  - [Redmine: #217894]
*/

ALTER TABLE dbo.EventPickingUpdateType
ADD [Group] VARCHAR(5000);

GO

UPDATE dbo.EventPickingUpdateType SET [Group] = 'New' WHERE [Id] = 1;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'KO Time' WHERE [Id] = 2;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'League' WHERE [Id] = 3;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Team' WHERE [Id] = 4;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'TV' WHERE [Id] = 5;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'TV' WHERE [Id] = 6;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'IPTV' WHERE [Id] = 7;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'IPTV' WHERE [Id] = 8;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Other Provider' WHERE [Id] = 9;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Other Provider' WHERE [Id] = 10;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Delete' WHERE [Id] = 11;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Round' WHERE [Id] = 12;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Round' WHERE [Id] = 13;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Remark' WHERE [Id] = 16;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Remark' WHERE [Id] = 17;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Home Remark' WHERE [Id] = 18;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Home Remark' WHERE [Id] = 19;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Away Remark' WHERE [Id] = 20;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Away Remark' WHERE [Id] = 21;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Division' WHERE [Id] = 22;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Division' WHERE [Id] = 23;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'KO Date' WHERE [Id] = 24;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Renew' WHERE [Id] = 25;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Postponed' WHERE [Id] = 26;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Cancelled' WHERE [Id] = 27;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Round Confirm' WHERE [Id] = 28;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Round Confirm' WHERE [Id] = 29;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'ETPK' WHERE [Id] = 48;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'ETPK' WHERE [Id] = 49;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Team' WHERE [Id] = 50;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Team' WHERE [Id] = 51;
UPDATE dbo.EventPickingUpdateType SET [Group] = 'Suspended' WHERE [Id] = 52;
