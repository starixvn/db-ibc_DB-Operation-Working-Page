CREATE TABLE [dbo].[Assignment] (
    [AssignmentId]   INT            IDENTITY (1, 1) NOT NULL,
    [OWPMatchId]     INT            NOT NULL,
    [Bettype]        INT            NOT NULL,
    [AssignmentType] TINYINT        NOT NULL,
    [UserId]         INT            NULL,
    [AssignmentNote] NVARCHAR (200) NULL,
    CONSTRAINT [PK_Assignment] PRIMARY KEY NONCLUSTERED ([AssignmentId] ASC) ON [OWP_Index]
);






GO
CREATE CLUSTERED INDEX [CIX_Assignment]
    ON [dbo].[Assignment]([OWPMatchId] ASC, [Bettype] ASC, [AssignmentType] ASC);

