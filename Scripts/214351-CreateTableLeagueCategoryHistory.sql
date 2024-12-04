/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241203@Frankie
Task :  Update League Group
DB: bodb_OWP

Revisions:
    20241203@Frankie: Create new table LeagueCategoryHistory - [Redmine: #214351]
*/

CREATE TABLE LeagueCategoryHistory (
    Id INT IDENTITY PRIMARY KEY,
    OWPLeagueId INT NOT NULL,
    LeagueCategoryId INT NOT NULL, 
    EffectiveDate DATETIME NOT NULL,   
    ExpiryDate DATETIME NULL   
);

GO

