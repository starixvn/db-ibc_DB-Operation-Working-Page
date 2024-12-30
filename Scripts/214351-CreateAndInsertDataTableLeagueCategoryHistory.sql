/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241203@Frankie
Task :  Update League Group
DB: bodb_OWP

Revisions:
    20241203@Frankie: Update League Group - [Redmine: #214351]
*/

CREATE TABLE LeagueCategoryHistory (
    Id INT IDENTITY PRIMARY KEY,
    OWPLeagueId INT NOT NULL, 
    CategoryId INT NOT NULL, 
    StartDate DATETIME NOT NULL,   
    EndDate DATETIME NULL   
);

--add new league group
UPDATE [dbo].[RefResource]
SET [Order] = [ResourceId]
WHERE [RefName] = 'LeagueCategory';

UPDATE [dbo].[RefResource]
SET [Order] = [Order] + 1
WHERE [RefName] = 'LeagueCategory' AND [Order] >= 14;

INSERT INTO [dbo].[RefResource] values ('LeagueCategory', 20, 'MJ.T3',14)
INSERT INTO [dbo].[RefResource] values ('LeagueCategory', 21, 'Cop.A',21)

--insert data to [LeagueCategoryHistory]
INSERT INTO [dbo].[LeagueCategoryHistory] ([OWPLeagueId], [CategoryId], [StartDate], [EndDate])
SELECT 
    [OWPLeagueId], 
    [CategoryId],
    '2020-01-01',
    NULL
FROM [dbo].[OWPLeague] 
WHERE [CategoryId] IS NOT NULL 
	AND [CategoryId] > 0

GO