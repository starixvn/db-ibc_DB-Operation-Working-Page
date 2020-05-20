
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AssginmentUpload_MatchOffersInsertOrUpdate] @MatchOffers NVARCHAR(MAX)
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpTable
     (MatchId INT, 
      [Name]  NVARCHAR(500)
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @MatchOffers;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   MatchId, 
                   [Name]
            FROM OPENXML(@idoc, '/Root/MatchAgent', 1) WITH(MatchId INT, [Name] NVARCHAR(500));
     EXEC sp_xml_removedocument 
          @idoc;

     -- DELETE Match Offer
     DELETE ma
     FROM dbo.MatchOfferDetail ma
          INNER JOIN #tmpTable t ON t.MatchId = ma.OWPMatchId;

     -- INSERT Match Offer
     INSERT INTO dbo.MatchOfferDetail
     (OWPMatchId, 
      MatchOfferId
     )
            SELECT DISTINCT 
                   t.MatchId, 
                   a.ResourceId
            FROM #tmpTable t
                 INNER JOIN dbo.RefResource a WITH(NOLOCK) ON t.[Name] = a.[Value]
                                                              AND a.RefName = 'MatchOffer';
     -- DROP tmpTable
     DROP TABLE #tmpTable;