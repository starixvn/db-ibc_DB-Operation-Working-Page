
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_UpdateInfositeId] @Xml NVARCHAR(MAX)
AS

/*  
Created: 20200824@Jacob  
Task : Infosite-Link matches between two sites
DB: bodb_OWP  
  
Revisions:  
	20200824@Jacob: Infosite-Link matches between two sites - [Redmine: #140195]   
*/

     SET NOCOUNT ON;
     CREATE TABLE #tmpTable
     (OWPMatchId       INT, 
      InfositeMatchId  INT, 
      AdminsiteMatchId INT, 
      EventDateTime    DATETIME
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @Xml;
     INSERT INTO #tmpTable
            SELECT DISTINCT 
                   OWPMatchId, 
                   InfositeMatchId, 
                   AdminsiteMatchId, 
                   EventDateTime
            FROM OPENXML(@idoc, '/Root/Row', 1) WITH(OWPMatchId INT, InfositeMatchId INT, AdminsiteMatchId INT, EventDateTime DATETIME);
     EXEC sp_xml_removedocument 
          @idoc;

     -- Update OWPMatch   
     UPDATE m
       SET 
           m.InfoSiteMatchId = t.InfositeMatchId
     FROM OWPMatch m
          INNER JOIN #tmpTable t ON m.OWPMatchId = t.OWPMatchId
     WHERE ISNULL(m.InfoSiteMatchId, 0) = 0;

     -- DROP tmpTable  
     DROP TABLE #tmpTable;