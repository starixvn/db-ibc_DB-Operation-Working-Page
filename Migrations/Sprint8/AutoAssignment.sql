-- create table AutoAssignmentBettype
CREATE TABLE [dbo].[AutoAssignmentBettype] (
    [MinorBettypeId]      INT NOT NULL,
    [SchedulingBettypeId] INT NOT NULL,
    CONSTRAINT [PK_AutoAssignmentBettype] PRIMARY KEY CLUSTERED ([MinorBettypeId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_AutoAssignmentBettype_SchedulingBettypeId]
    ON [dbo].[AutoAssignmentBettype]([SchedulingBettypeId] ASC)
    ON [OWP_Index];
GO


-- create table AutoAssignmentRequest
CREATE TABLE [dbo].[AutoAssignmentRequest] (
    [RequestId]   VARCHAR (50) NOT NULL,
    [EventDate]   DATE         NOT NULL,
    [Status]      INT          NOT NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_AutoAssignmentRequest_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatorId]   INT          NOT NULL,
    CONSTRAINT [PK_AutoAssignmentRequest] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_AutoAssignmentRequest_CreatorId]
    ON [dbo].[AutoAssignmentRequest]([CreatorId] ASC)
    ON [OWP_Index];
GO

CREATE NONCLUSTERED INDEX [IX_AutoAssignmentRequest_Status]
    ON [dbo].[AutoAssignmentRequest]([Status] ASC)
    ON [OWP_Index];
GO


-- create table AutoAssignmentResult
CREATE TABLE [dbo].[AutoAssignmentResult] (
    [RequestId]  VARCHAR (50) NOT NULL,
    [OWPMatchId] INT          NOT NULL,
    [Bettype]    INT          NOT NULL,
    [UserId]     INT          NULL,
    CONSTRAINT [PK_AutoAssignmentResult] PRIMARY KEY CLUSTERED ([RequestId] ASC, [OWPMatchId] ASC, [Bettype] ASC)
);
GO


-- insert data AutoAssignmentBettype
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-109,28)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-108,27)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-107,26)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-106,25)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-105,24)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-104,23)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-103,22)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-102,21)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-101,20)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-100,19)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-99,18)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-98,17)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-97,16)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-96,15)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-95,29)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-94,30)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-93,31)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-92,32)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-91,33)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-90,34)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-15,14)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-14,35)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-13,13)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-12,12)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-11,11)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-10,10)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-9,9)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-7,36)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-6,2)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-4,37)
INSERT INTO dbo.AutoAssignmentBettype(MinorBettypeId, SchedulingBettypeId) VALUES (-3,1)