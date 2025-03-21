/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250321@Frankie
Task : quick add chat group
DB: bodb_OWP

Revisions:
	20250321@Frankie: Add column 'IsQuickAdd' table TicketIssue  - [Redmine: #271183]
*/

ALTER TABLE [dbo].[TicketIssue]
ADD IsQuickAdd BIT;