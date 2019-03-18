CREATE TABLE [dbo].[EmployeeWorkingShiftColor] (
    [ShiftId]     INT           IDENTITY (1, 1) NOT NULL,
    [ShiftCode]   NVARCHAR (50) NOT NULL,
    [Background]  VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Background] DEFAULT ('') NOT NULL,
    [Color]       VARCHAR (50)  CONSTRAINT [DF_EmployeeWorkingShiftColor_Color] DEFAULT ('') NOT NULL,
    [StartTime]   TIME (7)      NULL,
    [EndTime]     TIME (7)      NULL,
    [IsTimeShift] BIT           NOT NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftColor] PRIMARY KEY CLUSTERED ([ShiftId] ASC)
);








GO



GO


