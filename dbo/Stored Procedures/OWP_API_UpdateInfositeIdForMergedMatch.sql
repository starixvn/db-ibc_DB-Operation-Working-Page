
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_UpdateInfositeIdForMergedMatch] @MatchRelationEvents NVARCHAR(MAX)
AS

/*
Created: 20210428@Mira
Task : Infosite Integration - Merged Matches Resolution
DB: bodb_OWP

Revisions:
	20210428@Mira: Initial - [Redmine: #154249]
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #tmpTable
        (InfositeMatchId INT, 
         ParentMatchId   INT
        );
        CREATE TABLE #tmpExistDataTable
        (OldInfositeMatchId INT, 
         NewInfositeMatchId INT
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @MatchRelationEvents;
        INSERT INTO #tmpTable
               SELECT DISTINCT 
                      InfositeMatchId, 
                      ParentMatchId
               FROM OPENXML(@idoc, '/Root/MatchRelationEvent', 1) WITH(InfositeMatchId INT, ParentMatchId INT);
        EXEC sp_xml_removedocument 
             @idoc;

        --select exist infositeMatchId
        INSERT INTO #tmpExistDataTable
        (OldInfositeMatchId, 
         NewInfositeMatchId
        )
               SELECT DISTINCT 
                      t.InfositeMatchId, 
                      t.ParentMatchId
               FROM #tmpTable t
                    INNER JOIN dbo.InfoSiteMatch i WITH(NOLOCK) ON i.InfoSiteMatchId = t.InfositeMatchId
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM dbo.InfoSiteMatch i
                   WHERE i.InfoSiteMatchId = t.ParentMatchId
               );

        -- Update InfositeMatch table
        UPDATE i
          SET 
              i.InfoSiteMatchId = t.NewInfositeMatchId
        FROM dbo.InfoSiteMatch i WITH(NOLOCK)
             INNER JOIN #tmpExistDataTable t ON i.InfoSiteMatchId = t.OldInfositeMatchId;

        -- Update OWPMatch
        UPDATE o
          SET 
              o.InfoSiteMatchId = t.NewInfositeMatchId
        FROM dbo.OWPMatch o WITH(NOLOCK)
             INNER JOIN #tmpExistDataTable t ON o.InfoSiteMatchId = t.OldInfositeMatchId;

        -- DROP tmpTable
        DROP TABLE #tmpTable;
		DROP TABLE #tmpExistDataTable;
    END;