CREATE TABLE [dbo].[UserRemark] (
    [UserId] INT            NOT NULL,
    [Remark] NVARCHAR (200) NULL,
    [Group]  INT            NOT NULL,
    CONSTRAINT [PK_UserRemark] PRIMARY KEY CLUSTERED ([UserId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRemark_UserId_Group]
    ON [dbo].[UserRemark]([UserId] ASC, [Group] ASC);

