
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_UpdateMaxbetSpread] @XML     NVARCHAR(MAX), 
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
                      NULLIF(SpreadOu, ''), 
                      NULLIF(SpreadHdp, ''), 
                      NULLIF(MaxbetHdp, ''), 
                      NoOfHDP
               FROM OPENXML(@idoc, '/Root/UpdateEvents', 1) WITH(InfoSiteMatchId INT, SpreadOu MONEY, SpreadHdp MONEY, MaxbetHdp MONEY, NoOfHDP NVARCHAR(2000));
        EXEC sp_xml_removedocument 
             @idoc;
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX), @ActionName NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        SET @XmlLogOld =
        (
            SELECT e.InfoSiteMatchId, 
                   e.MaxbetHdp, 
                   e.NoOfHDP, 
                   e.SpreadHdp, 
                   e.SpreadOu
            FROM EventPicking e
                 INNER JOIN #tbltemp t ON e.InfositeMatchId = t.InfoSiteMatchId FOR XML PATH('z'), ROOT('r')
        );
        UPDATE e
          SET 
              MaxbetHdp = temp.MaxbetHdp, 
              SpreadHdp = temp.SpreadHdp, 
              SpreadOu = temp.SpreadOu, 
              NoOfHDP = temp.NoOfHDP
        FROM EventPicking e
             INNER JOIN #tbltemp temp ON e.InfositeMatchId = temp.InfoSiteMatchId;
        INSERT INTO EventPicking
        (InfositeMatchId, 
         MaxbetHdp, 
         SpreadHdp, 
         SpreadOu, 
         NoOfHDP
        )
               SELECT temp.InfositeMatchId, 
                      temp.MaxbetHdp, 
                      temp.SpreadHdp, 
                      temp.SpreadOu, 
                      temp.NoOfHDP
               FROM #tbltemp temp
                    LEFT JOIN EventPicking e ON temp.InfositeMatchId = e.InfositeMatchId
               WHERE e.InfositeMatchId IS NULL;

        --Write log
        SET @XmlLogNew =
        (
            SELECT t.InfoSiteMatchId, 
                   t.MaxbetHdp, 
                   t.NoOfHDP, 
                   t.SpreadHdp, 
                   t.SpreadOu
            FROM #tbltemp t FOR XML PATH('z'), ROOT('r')
        );
        SET @LogNew = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogNew), '" />', '"/"');
        SET @LogOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogOld), '" />', '"/"');
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_EventPicking_UpdateMaxbetSpread', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = @LogNew, 
             @DataOld = @LogOld;
        DROP TABLE #tbltemp;
    END;