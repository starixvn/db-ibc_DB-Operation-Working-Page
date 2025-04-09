/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 222379@frankie
Task : sort update type filter
DB: bodb_OWP	

Revisions:
	20250408@Frankie: sort update type filter - [Redmine: #222379]
*/

ALTER TABLE dbo.EventPickingUpDateType
ADD DisplayOrder INT NOT NULL DEFAULT 0;

UPDATE dbo.EventPickingUpDateType 
SET DisplayOrder = CASE 
    WHEN [Group] = 'New Match' THEN 1
	WHEN [Group] = 'KO Time' THEN 2
	WHEN [Group] = 'League Name' THEN 3
	WHEN [Group] = 'Team Name' THEN 4
	WHEN [Group] = 'TV' THEN 5
	WHEN [Group] = 'IPTV' THEN 6
	WHEN [Group] = 'Other Provider' THEN 7
	WHEN [Group] = 'Provider' THEN 8
	WHEN [Group] = 'Deleted Match' THEN 9
	WHEN [Group] = 'Round' THEN 10
	WHEN [Group] = 'Remark' THEN 11
	WHEN [Group] = 'Home Remark' THEN 12
	WHEN [Group] = 'Away Remark' THEN 13
	WHEN [Group] = 'Division' THEN 14
	WHEN [Group] = 'Move KO Date' THEN 15
	WHEN [Group] = 'Renew Match' THEN 16
	WHEN [Group] = 'Match Postponed' THEN 17
	WHEN [Group] = 'Match Cancelled' THEN 18
	WHEN [Group] = 'Match Suspended' THEN 19
	WHEN [Group] = 'Round Confirm' THEN 20
	WHEN [Group] = 'AdminSiteID' THEN 21
	WHEN [Group] = 'Channel' THEN 22
	WHEN [Group] = 'Agent' THEN 23
	WHEN [Group] = 'Venue' THEN 24
	WHEN [Group] = 'ETPK' THEN 25
    ELSE 99
END;