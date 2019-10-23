
/*
	Created: Kane.Le
	Date: 20191017
	Task: schema [Redmine: #121765]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO
DROP INDEX Provider.IX_Provider_ProviderName;
GO
-- add column ProviderName max length 2000

ALTER TABLE Provider ALTER COLUMN ProviderName NVARCHAR(2000) NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_Provider_ProviderName ON dbo.Provider(ProviderName ASC);
GO
DROP INDEX OtherProvider.IX_OtherProvider_OtherProviderName;
GO
-- add column OtherProviderName max length 2000

ALTER TABLE OtherProvider ALTER COLUMN OtherProviderName NVARCHAR(2000) NOT NULL;
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_OtherProvider_OtherProviderName ON dbo.OtherProvider(OtherProviderName ASC);
GO