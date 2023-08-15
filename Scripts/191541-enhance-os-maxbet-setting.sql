
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230810@Mira
Task : Enhance OS maxbet setting
DB: bodb_OWP	

Revisions:
	20230810@Mira: Add IsActive and initial data [Redmine: #191541]
*/

-- Add IsActive column
ALTER TABLE dbo.OSLeagueSetting
ADD IsActive BIT NOT NULL
                 DEFAULT 0;

-- Initial IsActive for league settings
UPDATE ols
  SET 
      IsActive = ol.IsActive
FROM dbo.OSLeagueSetting ols
     INNER JOIN dbo.OSLeague ol WITH(NOLOCK) ON ol.OSLeagueId = ols.OSLeagueId;