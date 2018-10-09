CREATE TABLE [dbo].[EmployeeWorkingShift] (
    [EmployeeId]     INT          NOT NULL,
    [ShiftCode]      VARCHAR (50) NOT NULL,
    [ShiftDate]      DATE         NOT NULL,
    [ShiftStartTime] DATETIME     NULL,
    [ShiftEndTime]   DATETIME     NULL,
    CONSTRAINT [PK_EmployeeWorkingShift] PRIMARY KEY CLUSTERED ([EmployeeId] ASC, [ShiftDate] ASC)
);



