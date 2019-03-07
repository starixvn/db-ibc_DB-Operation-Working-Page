CREATE TABLE [dbo].[EmployeeWorkingShiftDefault] (
    [UserId]       INT      NOT NULL,
    [DayOfTheWeek] SMALLINT NOT NULL,
    [ShiftId]      INT      NOT NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftDefault] PRIMARY KEY CLUSTERED ([UserId] ASC, [DayOfTheWeek] ASC)
);

