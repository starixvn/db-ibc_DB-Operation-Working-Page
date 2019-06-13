/*
	Created: Kane.Le
	Date: 20190530
	Task: [Redmine: #112737]
	DB: bodb_OWP
*/
USE bodb_OWP

CREATE TABLE [dbo].[EmployeeWorkingShiftPublish] (
    [SectionId]         INT      NOT NULL,
    [FromDate]          DATETIME NOT NULL,
    [ToDate]            DATETIME NOT NULL,
    [IsPublished]       BIT      CONSTRAINT [DF_EmployeeWorkingShiftPublish_IsPublished] DEFAULT ((0)) NULL,
    [LastPublishedById] INT      NULL,
    [LastPublishedDate] DATETIME CONSTRAINT [DF_EmployeeWorkingShiftPublish_LastPublishedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftPublish] PRIMARY KEY CLUSTERED ([SectionId] ASC, [FromDate] ASC)
);
GO