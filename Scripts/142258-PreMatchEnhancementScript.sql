
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20200929@Tyler
Task : Pre-Match enhancement
DB: bodb_OWP	

Revisions:
	20200929@Tyler: Alter DB - [Redmine: #142258]
*/

ALTER TABLE [dbo].[PreMatchAssignment]
ADD AssignmentType TINYINT NOT NULL DEFAULT(1), 
    AssignmentNote NVARCHAR(200);

ALTER TABLE [dbo].[PreMatchAssignment]
DROP CONSTRAINT [PK_PreMatchAssignment]

ALTER TABLE [dbo].[PreMatchAssignment]
ADD CONSTRAINT [PK_PreMatchAssignment] PRIMARY KEY CLUSTERED ([PreMatchLeagueId] ASC,
	[UserId] ASC,
	[Bettype] ASC,
	[IsTakeOver] ASC,
	[AssignmentType] ASC)