CREATE TABLE [dbo].[EmployeeWorkingShiftNote] (
    [EmployeeWorkingShiftNoteId] INT             IDENTITY (1, 1) NOT NULL,
    [UserId]                     INT             NOT NULL,
    [CreatedDate]                DATETIME        NOT NULL,
    [CreatedBy]                  INT             NOT NULL,
    [Note]                       NVARCHAR (4000) NOT NULL,
    [ShiftDate]                  DATETIME        NOT NULL
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EmployeeWorkingShiftNote_UserId_ShiftDate]
    ON [dbo].[EmployeeWorkingShiftNote]([UserId] ASC, [ShiftDate] ASC);

