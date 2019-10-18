CREATE TABLE [dbo].[Provider] (
    [ProviderId]   INT             IDENTITY (1, 1) NOT NULL,
    [ProviderName] NVARCHAR (2000) NULL,
    CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED ([ProviderId] ASC)
);








GO


