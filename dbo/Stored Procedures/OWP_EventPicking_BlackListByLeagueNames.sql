
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_BlackListByLeagueNames] @LeagueNames NVARCHAR(MAX)
AS

/*
Created: 20210407@Carlos.Nguyen
Task : Export picking priority
DB: bodb_OWP

Revisions:
	20210407@Carlos.Nguyen: Initial - [Redmine: #150269]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempLeagueName TABLE(LeagueName NVARCHAR(500));
        INSERT INTO @tempLeagueName
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@LeagueNames, ',') u OPTION(MAXRECURSION 0);
        
		SELECT tmpl.LeagueName,
			owpl.IsBlackList
		FROM @tempLeagueName AS tmpl
			INNER JOIN OwpLeague AS owpl WITH (NOLOCK)
			ON tmpl.LeagueName=owpl.OWPLeagueName
		
    END;