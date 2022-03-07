
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_UpdateInfositeIdForMergedMatch] @MatchRelationEvents NVARCHAR(MAX)
AS

/*
Created: 20210428@Mira
Task : Infosite Integration - Merged Matches Resolution
DB: bodb_OWP

Revisions:
	20210428@Mira: Initial - [Redmine: #154249]
	20210914@Mira: Insert Service Log - [Redmine: #161379]
	20211112@Mira: Modify merge match behavior - [Redmine: #164484]
	20220304@Mira: Update adminsiteMatchId - [Redmine: #169279]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @LogDate DATETIME= GETDATE();
        CREATE TABLE #tmpTable
        (InfositeMatchId INT, 
         ParentMatchId   INT
        );
        CREATE TABLE #tmpLog
        (DataOld         NVARCHAR(MAX), 
         DataNew         NVARCHAR(MAX), 
         UpdatedField    NVARCHAR(100), 
         TableName       NCHAR(100), 
         OWPMatchId      INT, 
         InfoSiteMatchId INT
        );

        -- Parse data
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

        -- Write temp Log before updating InfoSiteMatch
        INSERT INTO #tmpLog
        ([DataOld], 
         [DataNew], 
         [UpdatedField], 
         [TableName], 
         [OWPMatchId], 
         [InfoSiteMatchId]
        )
               SELECT i.ParentId, 
                      t.ParentMatchId, 
                      'ParentId', 
                      'InfoSiteMatch', 
                      NULL, 
                      i.InfoSiteMatchId
               FROM dbo.InfoSiteMatch i WITH(ROWLOCK)
                    INNER JOIN #tmpTable t ON i.InfoSiteMatchId = t.InfositeMatchId
                                              AND (i.ParentId IS NULL
                                                   OR i.ParentId <> t.ParentMatchId);

        -- Update InfositeMatch table
        UPDATE i
          SET 
              i.ParentId = t.ParentMatchId
        FROM dbo.InfoSiteMatch i WITH(ROWLOCK)
             INNER JOIN #tmpTable t ON i.InfoSiteMatchId = t.InfositeMatchId
                                       AND (i.ParentId IS NULL
                                            OR i.ParentId <> t.ParentMatchId);

        -- Write temp Log before updating OWPMatch
        INSERT INTO #tmpLog
        ([DataOld], 
         [DataNew], 
         [UpdatedField], 
         [TableName], 
         [OWPMatchId]
        )
               SELECT CAST(o.InfoSiteMatchId AS VARCHAR) + ',' + CAST(o.MatchId AS VARCHAR), 
                      CAST(t.ParentMatchId AS VARCHAR) + ',' + CAST(im.AdminSiteMatchId AS VARCHAR), 
                      'InfoSiteMatchId, MatchId', 
                      'OWPMatch', 
                      o.OWPMatchId
               FROM dbo.OWPMatch o WITH(ROWLOCK)
                    INNER JOIN #tmpTable t ON o.InfoSiteMatchId = t.InfositeMatchId
                    INNER JOIN dbo.InfoSiteMatch im ON im.InfoSiteMatchId = t.ParentMatchId;

        -- Update OWPMatch
        UPDATE o
          SET 
              o.InfoSiteMatchId = t.ParentMatchId, 
              o.MatchId = im.AdminSiteMatchId
        FROM dbo.OWPMatch o WITH(ROWLOCK)
             INNER JOIN #tmpTable t ON o.InfoSiteMatchId = t.InfositeMatchId
             INNER JOIN dbo.InfoSiteMatch im ON im.InfoSiteMatchId = t.ParentMatchId;

        -- Insert Service Log
        INSERT INTO dbo.ServiceActionLog
        ([ActionBy], 
         [LogDate], 
         [DataOld], 
         [DataNew], 
         [UpdatedField], 
         [TableName], 
         [OWPMatchId], 
         [InfoSiteMatchId], 
         [SPName]
        )
               SELECT 'MergeMatch', 
                      @LogDate, 
                      DataOld, 
                      DataNew, 
                      UpdatedField, 
                      TableName, 
                      OWPMatchId, 
                      InfoSiteMatchId, 
                      'OWP_API_UpdateInfositeIdForMergedMatch'
               FROM #tmpLog t;

        -- DROP tmpTable
        DROP TABLE #tmpTable;
        DROP TABLE #tmpLog;
    END;