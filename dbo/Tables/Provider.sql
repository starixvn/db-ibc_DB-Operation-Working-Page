CREATE TABLE [dbo].[Provider] (
    [ProviderId]   INT             IDENTITY (1, 1) NOT NULL,
    [ProviderName] NVARCHAR (2000) NOT NULL,
    CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED ([ProviderId] ASC)
);












GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Provider_ProviderName]
    ON [dbo].[Provider]([ProviderName] ASC);

