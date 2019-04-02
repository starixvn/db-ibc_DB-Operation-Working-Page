CREATE TABLE [dbo].[User] (
    [UserId]            INT            NOT NULL,
    [FullName]          NVARCHAR (100) NULL,
    [ProfilePic]        VARCHAR (500)  NULL,
    [Nickname]          VARCHAR (30)   NULL,
    [EmployeeId]        VARCHAR (30)   NULL,
    [Skype]             VARCHAR (50)   NULL,
    [DepartmentId]      SMALLINT       NULL,
    [SectionId]         SMALLINT       NULL,
    [Extension]         VARCHAR (30)   NULL,
    [Phone]             VARCHAR (30)   NULL,
    [Email]             VARCHAR (50)   NULL,
    [LocationCode]      VARCHAR (10)   NULL,
    [CategoryId]        SMALLINT       NULL,
    [Username]          VARCHAR (30)   NULL,
    [Pickup]            BIT            NULL,
    [Address]           NVARCHAR (500) NULL,
    [Level]             INT            NULL,
    [TimeZoneSettingId] SMALLINT       NULL,
    [IsSecondAccount]   BIT            CONSTRAINT [DF__User__IsSecondAc__1FA39FB9] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserId] ASC)
);














GO
CREATE NONCLUSTERED INDEX [IX_SectionId]
    ON [dbo].[User]([SectionId] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_Nickname]
    ON [dbo].[User]([Nickname] ASC)
    ON [OWP_Index];


GO
CREATE NONCLUSTERED INDEX [IX_DepartmentId]
    ON [dbo].[User]([DepartmentId] ASC)
    ON [OWP_Index];

