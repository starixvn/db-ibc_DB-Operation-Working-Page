/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250612@Frankie
Task : Fast create discussion rocket chat
DB: bodb_OWP

Revisions:
	20250612@Frankie: add more column to save info discussion [Feature: #229399]
*/

ALTER TABLE TicketIssue
ADD IsRC BIT DEFAULT 0,
    DiscussionName VARCHAR(100) NULL,
    ChannelRC VARCHAR(100) NULL;





