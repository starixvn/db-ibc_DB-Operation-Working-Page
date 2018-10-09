CREATE TABLE [dbo].[Assignment] (
    [AssignmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]     INT            NOT NULL,
    [Bettype]        INT            NOT NULL,
    [AssignmentType] TINYINT        NOT NULL,
    [UserId]         INT            NULL,
    [AssignmentNote] NVARCHAR (200) NULL,
    CONSTRAINT [PK_Assignment] PRIMARY KEY CLUSTERED ([AssignmentId] ASC)
);



