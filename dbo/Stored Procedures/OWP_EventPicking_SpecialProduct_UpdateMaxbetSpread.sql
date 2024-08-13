
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_SpecialProduct_UpdateMaxbetSpread] @TargetJson     NVARCHAR(MAX), 
                                                            @ActorId INT

/*      
 Created: 20240813@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240813@Los: update events   - [Redmine: #207942]

*/

AS
    BEGIN
        SET NOCOUNT ON;
       
        CREATE TABLE #tbltemp
        (ParentId INT,
			MinorBettypeId INT,
         SpreadOu        MONEY, 
         SpreadHdp       MONEY, 
         MaxbetHdp       MONEY, 
         NoOfHDP         NVARCHAR(2000)
        );
        INSERT INTO #tbltemp
        (ParentId,
		MinorbettypeId,
         SpreadOu, 
         SpreadHdp, 
         MaxbetHdp, 
         NoOfHDP
        )
               SELECT ParentId,
			   MinorBettypeId,
                      NULLIF(SpreadOu, ''), 
                      NULLIF(SpreadHdp, ''), 
                      NULLIF(MaxbetHdp, ''), 
					  NoOfHDP
              FROM OPENJSON(@TargetJson) WITH(ParentId INT, MinorBettypeId INT, SpreadOu NVARCHAR(2000), SpreadHdp NVARCHAR(2000), MaxbetHdp NVARCHAR(2000), NoOfHDP NVARCHAR(2000));
      
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX), @ActionName NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        SET @XmlLogOld =
        (
            SELECT e.ParentId 'ParentMatchId',
			e.MinorBettypeId,
                   e.MaxbetHdp, 
                   e.NoOfHDP, 
                   e.SpreadHdp, 
                   e.SpreadOu
            FROM EventPickingChildMatch e WITH(NOLOCK)
                 INNER JOIN #tbltemp t ON e.ParentId = t.ParentId AND t.MinorBettypeId=e.MinorBettypeId FOR XML PATH('z'), ROOT('r')
        );

		
        UPDATE e
          SET 
              MaxbetHdp = temp.MaxbetHdp, 
              SpreadHdp = temp.SpreadHdp, 
              SpreadOu = temp.SpreadOu, 
              NoOfHDP = temp.NoOfHDP
        FROM EventPickingChildMatch e WITH(NOLOCK)
             INNER JOIN #tbltemp temp ON e.ParentId = temp.ParentId AND temp.MinorBettypeId=e.MinorBettypeId;
      

        --Write log
        SET @XmlLogNew =
        (
            SELECT t.ParentId 'ParentMatchId',
			t.MinorBettypeId,
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
             @SPName = 'OWP_EventPicking_SpecialProduct_UpdateMaxbetSpread', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = @LogNew, 
             @DataOld = @LogOld;
        DROP TABLE #tbltemp;
    END;