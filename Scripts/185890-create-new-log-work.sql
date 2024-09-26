
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20230602@Liam.Pham
Task : Create table TicketIssueLogWork
DB: bodb_OWP	

Revisions:
	20230602@Liam.Pham: Create table TicketIssueLogWork [Redmine: #185890]
*/

-- Table TicketIssueLogWork
IF OBJECT_ID('dbo.TicketIssueLogWork', 'U') IS NOT NULL
    DROP TABLE dbo.[TicketIssueLogWork]; 
GO

CREATE TABLE [dbo].[TicketIssueLogWork]
([Id]          INT IDENTITY(1, 1) PRIMARY KEY, 
 [TicketId]    [INT] NOT NULL, 
 [Subject]     NVARCHAR(2000), 
 [AdminsiteId] [INT], 
)
ON [OWP_Data];
GO

INSERT INTO [dbo].[TicketType]
(TypeId, 
 TypeName
)
VALUES
(5, 
 'S&VR'
);

SET IDENTITY_INSERT TicketSubtype ON;
INSERT INTO TicketSubtype
(SubtypeId, 
 SubtypeName, 
 TypeId
)
VALUES
(20, 
 'Ticket Check', 
 5
);
INSERT INTO TicketSubtype
(SubtypeId, 
 SubtypeName, 
 TypeId
)
VALUES
(21, 
 'Match Check', 
 5
);
INSERT INTO TicketSubtype
(SubtypeId, 
 SubtypeName, 
 TypeId
)
VALUES
(22, 
 'CSD Support', 
 5
);
INSERT INTO TicketSubtype
(SubtypeId, 
 SubtypeName, 
 TypeId
)
VALUES
(23, 
 'VIP Support', 
 5
);
INSERT INTO TicketSubtype
(SubtypeId, 
 SubtypeName, 
 TypeId
)
VALUES
(24, 
 'Others', 
 5
);
SET IDENTITY_INSERT TicketSubtype OFF;


