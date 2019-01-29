CREATE TABLE [dbo].[EmployeeWorkingShiftColor_Old] (
    [Name]       NVARCHAR (50) NOT NULL,
    [Background] VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Background_Old] DEFAULT ('') NOT NULL,
    [Color]      VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Color_Old] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftColor_Old] PRIMARY KEY CLUSTERED ([Name] ASC)
);

