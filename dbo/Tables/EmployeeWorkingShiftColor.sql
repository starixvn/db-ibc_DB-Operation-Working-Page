CREATE TABLE [dbo].[EmployeeWorkingShiftColor] (
    [Name]       NVARCHAR (50) NOT NULL,
    [Background] VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Background] DEFAULT ('') NOT NULL,
    [Color]      VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Color] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftColor] PRIMARY KEY CLUSTERED ([Name] ASC)
);

