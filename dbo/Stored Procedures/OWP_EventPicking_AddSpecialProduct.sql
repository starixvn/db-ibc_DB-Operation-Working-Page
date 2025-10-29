
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_AddSpecialProduct]	@ChildMatches XML, 
															@ActorId        INT
AS

/*      
 Created: 20240809@Johnny
 Task : Add special product
 DB: bodb_OWP      
 
 Revisions:
    20240809@Johnny: Init sp  - [Redmine: #207942]
    20251023@Hank: Modified to use XML model handling for ChildMatchModel - [Redmine: #238985]

*/

    BEGIN
        SET NOCOUNT ON;

        DECLARE @idoc INT

        EXEC sp_xml_preparedocument @idoc OUTPUT, @ChildMatches

        CREATE TABLE #tblChildMatchData (
            ParentId       INT, 
            MinorBettypeId INT, 
            NoOfHDP        NVARCHAR(50), 
            MaxbetHdp      MONEY, 
            MaxbetOu       MONEY,
            SpreadHdp      MONEY, 
            SpreadOu       MONEY
        )

        INSERT INTO #tblChildMatchData (
            ParentId,
            MinorBettypeId,
            NoOfHDP,
            MaxbetHdp,
            MaxbetOu,
            SpreadHdp,
            SpreadOu
        )
        SELECT 
            ParentId,
            MinorBettypeId,
            NULLIF(NoOfHDP, '') AS NoOfHDP,
            NULLIF(MaxbetHdp, '') AS MaxbetHdp,
            NULLIF(MaxbetOu, '') AS MaxbetOu,
            NULLIF(SpreadHdp, '') AS SpreadHdp,
            NULLIF(SpreadOu, '') AS SpreadOu
        FROM OPENXML(@idoc, '/Root/SpecialProductMaxbetSpread', 1) WITH (
            ParentId       INT,
            MinorBettypeId INT,
            NoOfHDP        NVARCHAR(50),
            MaxbetHdp      MONEY,
            MaxbetOu       MONEY,
            SpreadHdp      MONEY,
            SpreadOu       MONEY
        )

        EXEC sp_xml_removedocument @idoc

        DECLARE @tempAdd TABLE
        (Id             INT IDENTITY(1, 1), 
         ParentId       INT, 
         MinorBettypeId INT, 
         NoOfHDP        MONEY, 
         MaxbetHdp      MONEY, 
         MaxbetOu       MONEY,
         SpreadHdp      MONEY, 
         SpreadOu       MONEY
        );

		INSERT INTO @tempAdd(ParentId, MinorBettypeId, NoOfHDP, MaxbetHdp, MaxbetOu, SpreadHdp, SpreadOu)
		SELECT 
			cmd.ParentId,
			cmd.MinorBettypeId,
			cmd.NoOfHDP,
			cmd.MaxbetHdp,
			cmd.MaxbetOu,
			cmd.SpreadHdp,
			cmd.SpreadOu
		FROM #tblChildMatchData AS cmd
		WHERE NOT EXISTS (
			SELECT 1 
			FROM EventPickingChildMatch e WITH(NOLOCK) 
			WHERE e.ParentId = cmd.ParentId 
			AND e.MinorBettypeId = cmd.MinorBettypeId
		)
		
        -- Insert data into main table
        INSERT INTO EventPickingChildMatch(ParentId, MinorBettypeId, NoOfHDP, MaxbetHDP, MaxbetOU, SpreadHDP, SpreadOU)
        SELECT ParentId,
               MinorBettypeId,
               NoOfHDP,
               MaxbetHdp,
               MaxbetOu,
               SpreadHdp,
               SpreadOu
        FROM   @tempAdd
		-- Log the operation
		DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSettingDataOld NVARCHAR(MAX), @XmlSettingOld XML, @XmlSettingNew XML, @LogInfoDataOld NVARCHAR(MAX), @LogInfoData NVARCHAR(MAX), @XmlInfoOld XML, @XmlInfoNew XML;
        SET @StartRun = GETDATE();
        DECLARE @LoopCounter INT= 1, @MaxRowCount INT, @RowNumber INT;
        SET @LoopCounter = 1;
        SELECT @MaxRowCount = COUNT(Id)
        FROM @tempAdd;
        WHILE(@LoopCounter <= @MaxRowCount)
            BEGIN
                SET @XmlSettingOld =
                (
                    SELECT l.ParentId, 
                           l.MinorBettypeId, 
                           l.NoOfHDP, 
                           l.MaxbetHdp, 
                           l.MaxbetOu,
                           l.SpreadHdp, 
                           l.SpreadOu
                    FROM @tempAdd AS l
                    WHERE Id = @LoopCounter FOR XML PATH('SpecialProductMaxbetSpread'), ROOT('SpecialProductMaxbetSpreads')
                );
                SET @LogSettingDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingOld), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_EventPicking_AddSpecialProduct', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = 1000, 
                     @Data = @LogSettingDataOld, 
                     @DataOld = NULL;
                SET @LoopCounter = @LoopCounter + 1;
            END;
            
        -- Clean up temp table
        DROP TABLE #tblChildMatchData
    END;