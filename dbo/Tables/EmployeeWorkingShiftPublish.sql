CREATE TABLE [dbo].[EmployeeWorkingShiftPublish] (
    [SectionId]         INT      NOT NULL,
    [FromDate]          DATETIME NOT NULL,
    [ToDate]            DATETIME NOT NULL,
    [IsPublished]       BIT      CONSTRAINT [DF__EmployeeW__IsPub__5046D714] DEFAULT ((0)) NULL,
    [LastPublishedById] INT      NULL,
    [LastPublishedDate] DATETIME CONSTRAINT [DF__EmployeeW__LastP__513AFB4D] DEFAULT (getdate()) NULL
);

