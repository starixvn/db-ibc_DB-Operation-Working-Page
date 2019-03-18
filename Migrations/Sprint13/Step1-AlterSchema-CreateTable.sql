/*
	Created: Leo.Vo
	Date: 2019-03-18
	Task: [Redmine: #110322]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema, create table
--------------------------------
USE bodb_OWP

CREATE TABLE [dbo].[EmployeeWorkingShiftOrder] (
    [UserId]     INT NOT NULL,
    [SectionId]  INT NOT NULL,
    [EmployeeId] INT NOT NULL,
    [OrderId]    INT NOT NULL
);

GO
