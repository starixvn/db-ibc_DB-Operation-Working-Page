CREATE TABLE [dbo].[UserRemark] (
    [UserId]   INT            NOT NULL,
    [Category] INT            NOT NULL,
    [Remark]   NVARCHAR (200) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserRemark_UserId_Category]
    ON [dbo].[UserRemark]([UserId] ASC, [Category] ASC);

