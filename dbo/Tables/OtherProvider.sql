CREATE TABLE [dbo].[OtherProvider] (
    [OtherProviderId]   INT            IDENTITY (1, 1) NOT NULL,
    [OtherProviderName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_OtherProvider] PRIMARY KEY CLUSTERED ([OtherProviderId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OtherProvider_OtherProviderName]
    ON [dbo].[OtherProvider]([OtherProviderName] ASC)
    ON [OWP_Index];

