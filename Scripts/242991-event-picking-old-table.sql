/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251111@Hank
Task : Create old table event picking log
DB: bodb_OWP

Revisions:
	20251111@Hank: Create old table event picking log - [Redmine: #242991]
*/
USE bodb_OWP;
GO

CREATE TABLE EventPickingLog_Old
(
    Id INT IDENTITY(1,1) NOT NULL,
    Date DATETIME NOT NULL,
    InfositeId INT NULL,
    UpdateTypeId INT NULL,
    ModifiedBy VARCHAR(5000) NULL,
    Action VARCHAR(5000) NULL,
    OldValue VARCHAR(5000) NULL,
    NewValue VARCHAR(5000) NULL,
    HomeUpdated BIT NULL,
    AwayUpdated BIT NULL,
	FromService NVARCHAR(50) NULL
)