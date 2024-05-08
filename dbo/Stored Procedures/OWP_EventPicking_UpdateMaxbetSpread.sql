
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_UpdateMaxbetSpread] @XML     NVARCHAR(MAX), 
                                                             @ActorId INT

/*      
 Created: 20240429@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240429@Liam: update events   - [Redmine: #202639]

*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        CREATE TABLE #tbltemp
        (InfoSiteMatchId INT, 
         SpreadOu        MONEY, 
         SpreadHdp       MONEY, 
         MaxbetHdp       MONEY, 
         NoOfHDP         NVARCHAR(2000)
        );
        INSERT INTO #tbltemp
        (InfoSiteMatchId, 
         SpreadOu, 
         SpreadHdp, 
         MaxbetHdp, 
         NoOfHDP
        )
               SELECT InfoSiteMatchId, 
                      SpreadOu, 
                      SpreadHdp, 
                      MaxbetHdp, 
                      NoOfHDP
               FROM OPENXML(@idoc, '/Root/Events', 1) WITH(InfoSiteMatchId INT, SpreadOu MONEY, SpreadHdp MONEY, MaxbetHdp MONEY, NoOfHDP NVARCHAR(2000));
        EXEC sp_xml_removedocument 
             @idoc;
        UPDATE EventPicking
          SET 
              MaxbetHdp = temp.MaxbetHdp, 
              SpreadHdp = temp.SpreadHdp, 
              SpreadOu = temp.SpreadOu, 
              NoOfHDP = temp.NoOfHDP
        FROM EventPicking e
             INNER JOIN #tbltemp temp ON e.InfositeMatchId = temp.InfoSiteMatchId;
        DROP TABLE #tbltemp;
    END;