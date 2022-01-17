
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20220112@Tyler
Task : Link to AdminSite matches
DB: bodb_OWP	

Revisions:
	20220112@Tyler: change col name - [Redmine: #167315]
*/

EXEC sp_rename 
     'dbo.OSMatch.MatchStatus', 
     'OfferLiveStatus', 
     'COLUMN';
ALTER TABLE dbo.OSMatch
ADD AdminSiteMatchId INT;
INSERT INTO [dbo].[Module]
([ModuleId], 
 [ModuleName]
)
VALUES
(13, 
 'OtherSport'
);
INSERT INTO [dbo].[ModuleObject]
([ModuleObjectId], 
 [ModuleObjectName], 
 [ModuleId]
)
VALUES
(41, 
 'Match', 
 13
);
INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(120, 
 13, 
 41, 
 1, 
 'OWP_OSSport_LinkAdminSiteMatch', 
 'OWP_OtherSport_UpdateUnlinkedMatches', 
 '<root><xml path="r/z" /><row item="League" alias="l" /><row item="Home" alias="h" /><row item="Away" alias="a" /><row item="AdminSiteMatchId" alias="aid" /><row item="EventDate" alias="e" /></root>'
);
INSERT INTO [dbo].[LogAction]
([ActionId], 
 [ModuleId], 
 [ModuleObjectId], 
 [ActionTypeId], 
 [ActionName], 
 [SPName], 
 [LogItems]
)
VALUES
(121, 
 13, 
 41, 
 2, 
 'OWP_OSSport_UpdateLinkedAdminSiteMatch', 
 'OWP_OtherSport_UpdateLinkedMatches', 
 '<root><xml path="r/z" /><row item="League" alias="l" /><row item="Home" alias="h" /><row item="Away" alias="a" /><row item="AdminSiteMatchId" alias="aid" /><row item="EventDate" alias="e" /></root>'
);