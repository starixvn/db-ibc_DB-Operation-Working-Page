
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
    20251023@Assistant: Modified to use XML model handling for ChildMatchModel - [Redmine: #238985]

*/

    BEGIN
        SET NOCOUNT ON;

        DECLARE @idoc INT

        -- Prepare XML document
        EXEC sp_xml_preparedocument @idoc OUTPUT, @ChildMatches

        -- Create temp table for XML data
        CREATE TABLE #tblChildMatchData (
            ParentMatchId  INT, 
            MinorBettypeId INT, 
            NoOfHDP        MONEY, 
            MaxbetHDP      MONEY, 
            MaxbetOU       MONEY,
            SpreadHDP      MONEY, 
            SpreadOU       MONEY
        )

        -- Parse XML data using OPENXML
        INSERT INTO #tblChildMatchData (
            ParentMatchId,
            MinorBettypeId,
            NoOfHDP,
            MaxbetHDP,
            MaxbetOU,
            SpreadHDP,
            SpreadOU
        )
        SELECT 
            ParentMatchId,
            MinorBettypeId,
            NULLIF(NoOfHDP, '') AS NoOfHDP,
            NULLIF(MaxbetHDP, '') AS MaxbetHDP,
            NULLIF(MaxbetOU, '') AS MaxbetOU,
            NULLIF(SpreadHDP, '') AS SpreadHDP,
            NULLIF(SpreadOU, '') AS SpreadOU
        FROM OPENXML(@idoc, '/Root/ChildMatchModel', 1) WITH (
            ParentMatchId  INT,
            MinorBettypeId INT,
            NoOfHDP        NVARCHAR(50),
            MaxbetHDP      NVARCHAR(50),
            MaxbetOU       NVARCHAR(50),
            SpreadHDP      NVARCHAR(50),
            SpreadOU       NVARCHAR(50)
        )

        -- Clean up XML document
        EXEC sp_xml_removedocument @idoc

        -- Create temp table for processing
        DECLARE @tempAdd TABLE
        (Id             INT IDENTITY(1, 1), 
         ParentMatchId  INT, 
         MinorBettypeId INT, 
         NoOfHDP        MONEY, 
         MaxbetHDP      MONEY, 
         MaxbetOU       MONEY,
         SpreadHDP      MONEY, 
         SpreadOU       MONEY
        );

		-- Use UNION logic like original - add records that don't already exist
		INSERT INTO @tempAdd(ParentMatchId, MinorBettypeId, NoOfHDP, MaxbetHDP, MaxbetOU, SpreadHDP, SpreadOU)
		SELECT 
			cmd.ParentMatchId,
			cmd.MinorBettypeId,
			cmd.NoOfHDP,
			cmd.MaxbetHDP,
			cmd.MaxbetOU,
			cmd.SpreadHDP,
			cmd.SpreadOU
		FROM #tblChildMatchData AS cmd
		WHERE cmd.ParentMatchId IN (SELECT e.ParentId FROM EventPickingChildMatch e WITH(NOLOCK)) 
		AND cmd.MinorBettypeId NOT IN(SELECT e.MinorBettypeId FROM EventPickingChildMatch e WITH(NOLOCK) WHERE e.ParentId = cmd.ParentMatchId)
		
        UNION
		
        SELECT 
			cmd.ParentMatchId,
			cmd.MinorBettypeId,
			cmd.NoOfHDP,
			cmd.MaxbetHDP,
			cmd.MaxbetOU,
			cmd.SpreadHDP,
			cmd.SpreadOU
		FROM #tblChildMatchData AS cmd
		LEFT JOIN EventPickingChildMatch AS e WITH(NOLOCK) ON cmd.ParentMatchId != e.ParentId
		WHERE cmd.ParentMatchId NOT IN (SELECT e.ParentId FROM EventPickingChildMatch e WITH(NOLOCK))
		
        -- Insert data into main table
        INSERT INTO EventPickingChildMatch(ParentId, MinorBettypeId, NoOfHDP, MaxbetHDP, MaxbetOU, SpreadHDP, SpreadOU)
        SELECT ParentMatchId,
               MinorBettypeId,
               NoOfHDP,
               MaxbetHDP,
               MaxbetOU,
               SpreadHDP,
               SpreadOU
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
                    SELECT l.ParentMatchId, 
                           l.MinorBettypeId, 
                           l.NoOfHDP, 
                           l.MaxbetHDP, 
                           l.MaxbetOU,
                           l.SpreadHDP, 
                           l.SpreadOU
                    FROM @tempAdd AS l
                    WHERE Id = @LoopCounter FOR XML PATH('ChildMatchModel'), ROOT('ChildMatchModels')
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