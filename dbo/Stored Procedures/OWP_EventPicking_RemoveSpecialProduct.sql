
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_RemoveSpecialProduct] @ParentId       VARCHAR(MAX), 
                                                              @MinorBettypeId VARCHAR(MAX), 
                                                              @ActorId        INT
AS

/*      
 Created: 20240808@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20240808@Los: Remove special product  - [Redmine: #207942]

*/

    BEGIN
        SET NOCOUNT ON;

        -- WRITE LOG
        DECLARE @tempDelete TABLE
        (Id             INT IDENTITY(1, 1), 
         ChildMatchId   INT, 
         ParentMatchId  INT, 
         MinorBettypeId INT, 
         NoOfHDP        MONEY, 
         MaxbetHDP      MONEY, 
         SpreadHDP      MONEY, 
         SpreadOU       MONEY
        );
        INSERT INTO @tempDelete
        (ChildMatchId, 
         ParentMatchId, 
         MinorBettypeId, 
         NoOfHDP, 
         MaxbetHDP, 
         SpreadHDP, 
         SpreadOU
        )
               SELECT l.Id, 
                      l.ParentId, 
                      l.MinorBettypeId, 
                      l.NoOfHDP, 
                      l.MaxbetHDP, 
                      l.SpreadHDP, 
                      l.SpreadOU
               FROM EventPickingChildMatch l WITH(NOLOCK)
                    INNER JOIN InfoSiteMatch AS i WITH(NOLOCK) ON l.ParentId = i.InfoSiteMatchId
               WHERE l.ParentId IN
               (
                   SELECT DISTINCT 
                          value
                   FROM STRING_SPLIT(@ParentId, ',')
               )
                     AND MinorBettypeId IN
               (
                   SELECT DISTINCT 
                          value
                   FROM STRING_SPLIT(@MinorBettypeId, ',')
               );
        DELETE cm
        FROM EventPickingChildMatch AS cm
             INNER JOIN @tempDelete AS temp ON cm.ParentId = temp.ParentMatchId
                                               AND cm.MinorBettypeId = temp.MinorBettypeId;
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @LogSettingDataOld NVARCHAR(MAX), @XmlSettingOld XML, @XmlSettingNew XML, @LogInfoDataOld NVARCHAR(MAX), @LogInfoData NVARCHAR(MAX), @XmlInfoOld XML, @XmlInfoNew XML;
        SET @StartRun = GETDATE();
        DECLARE @LoopCounter INT= 1, @MaxRowCount INT, @RowNumber INT;
        SET @LoopCounter = 1;
        SELECT @MaxRowCount = COUNT(Id)
        FROM @tempDelete;
        WHILE(@LoopCounter <= @MaxRowCount)
            BEGIN
                SET @XmlSettingOld =
                (
                    SELECT l.ParentMatchId, 
                           l.MinorBettypeId, 
                           l.NoOfHDP, 
                           l.MaxbetHDP, 
                           l.SpreadHDP, 
                           l.SpreadOU
                    FROM @tempDelete AS l
                    WHERE Id = @LoopCounter FOR XML PATH('z'), ROOT('r')
                );
                SET @LogSettingDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlSettingOld), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_EventPicking_RemoveSpecialProduct', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = 1000, 
                     @Data = NULL, 
                     @DataOld = @LogSettingDataOld;
                SET @LoopCounter = @LoopCounter + 1;
            END;
    END;