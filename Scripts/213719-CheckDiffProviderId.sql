/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250210@Los
Task :  add col IsMismatchEvent
DB: bodb_OWP

Revisions:
    20250210@Los: add col IsMismatchEvent - [Feature: #213719]
*/
ALTER TABLE ProviderVerification
ADD  IsMismatchEvent BIT;

CREATE TABLE LogMonitoring(
Id INT IDENTITY(1,1) PRIMARY KEY,
CreatedDate DATE,
[Action] VARCHAR(255) NOT NULL,
[Payload] NVARCHAR(MAX)
)

CREATE NONCLUSTERED INDEX idx_action
ON LogMonitoring ([Action]);


CREATE TABLE AdminsiteProviderMatch(
Id INT IDENTITY(1,1) PRIMARY KEY,
CreatedDate DATE,
MatchId INT NOT NULL,
ProviderMatchId INT NOT NULL,
ProviderId INT,
Provider VARCHAR(50)
)

CREATE NONCLUSTERED INDEX idx_matchId_providerMatchId
ON AdminsiteProviderMatch (MatchId,ProviderMatchId);



