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