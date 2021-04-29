
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

        -- Update
        UPDATE i
          SET 
              i.InfoSiteMatchId = t.ParentMatchId
        FROM dbo.InfoSiteMatch i WITH(NOLOCK)
             INNER JOIN #tmpTable t ON i.InfoSiteMatchId = t.InfositeMatchId;

        -- DROP tmpTable
        DROP TABLE #tmpTable;
    END;