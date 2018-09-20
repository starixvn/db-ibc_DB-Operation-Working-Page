CREATE TABLE [dbo].[EmployeeWorkingShiftNote] (
    [UserId] INT            NOT NULL,
    [Note]   NVARCHAR (200) NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftNote] PRIMARY KEY CLUSTERED ([UserId] ASC)
);



