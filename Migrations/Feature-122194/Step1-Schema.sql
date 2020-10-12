
/*
	Created: Kane.Le
	Date: 20191017
	Task: schema [Redmine: #121765]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

-- add column ProviderName max length 900
DROP INDEX Provider.IX_Provider_ProviderName;
ALTER TABLE Provider ALTER COLUMN ProviderName VARCHAR(900) NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX IX_Provider_ProviderName ON dbo.Provider(ProviderName ASC);
GO

-- add column OtherProviderName max length 900
DROP INDEX OtherProvider.IX_OtherProvider_OtherProviderName;
ALTER TABLE OtherProvider ALTER COLUMN OtherProviderName VARCHAR(900) NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX IX_OtherProvider_OtherProviderName ON dbo.OtherProvider(OtherProviderName ASC);
GO