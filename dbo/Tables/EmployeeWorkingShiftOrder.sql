CREATE TABLE [dbo].[EmployeeWorkingShiftOrder] (
    [UserId]     INT NOT NULL,
    [SectionId]  INT NOT NULL,
    [EmployeeId] INT NOT NULL,
    [OrderId]    INT NOT NULL
);




GO
CREATE CLUSTERED INDEX [CIX_EmployeeWorkingShiftOrder]
    ON [dbo].[EmployeeWorkingShiftOrder]([SectionId] ASC);

