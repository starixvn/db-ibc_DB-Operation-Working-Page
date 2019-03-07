CREATE TABLE [dbo].[EmployeeWorkingShift] (
    [EmployeeId]     INT      NOT NULL,
    [ShiftId]        INT      NOT NULL,
    [ShiftDate]      DATE     NOT NULL,
    [ShiftStartTime] DATETIME NULL,
    [ShiftEndTime]   DATETIME NULL,
    CONSTRAINT [PK_EmployeeWorkingShift] PRIMARY KEY CLUSTERED ([EmployeeId] ASC, [ShiftDate] ASC)
);










GO
CREATE NONCLUSTERED INDEX [IX_EmployeeWorkingShift_ShiftId]
    ON [dbo].[EmployeeWorkingShift]([ShiftId] ASC)
    ON [OWP_Index];

