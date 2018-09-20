CREATE TABLE [dbo].[UserRole] (
    [UserId] INT      NOT NULL,
    [RoleId] SMALLINT NOT NULL,
    CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC)
);

