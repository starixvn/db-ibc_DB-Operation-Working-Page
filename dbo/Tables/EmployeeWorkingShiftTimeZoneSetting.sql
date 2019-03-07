CREATE TABLE [dbo].[EmployeeWorkingShiftTimeZoneSetting] (
    [SettingId] SMALLINT      NOT NULL,
    [Name]      NVARCHAR (20) NOT NULL,
    [IsDefault] BIT           NOT NULL,
    [Offset]    SMALLINT      NOT NULL,
    CONSTRAINT [PK_EmployeeWorkingShiftTimeZoneSetting] PRIMARY KEY CLUSTERED ([SettingId] ASC)
);

