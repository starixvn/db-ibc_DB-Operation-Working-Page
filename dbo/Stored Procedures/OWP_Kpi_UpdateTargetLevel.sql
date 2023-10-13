
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Kpi_UpdateTargetLevel] @TargetJson NVARCHAR(MAX), 
                                                  @ActorId    INT
AS

/*
Created: 20230918@Mira
Task : LA KPI phase 2
DB: bodb_OWP	

Revisions:
	20230918@Mira: add table setting for LA level - [Redmine: #193488]
	20231012@Mira: write log - [Redmine: #195223]
*/

    BEGIN
        DECLARE @StartRun DATETIME= GETDATE();
        SET NOCOUNT ON;
        -- parse data
        DECLARE @Temp TABLE
        (UserId      INT NOT NULL, 
         TargetId    INT, 
         OldTargetId INT
        );
        INSERT INTO @Temp
        (UserId, 
         TargetId, 
         OldTargetId
        )
               SELECT a.UserId, 
                      a.TargetId, 
                      ls.TargetId
               FROM OPENJSON(@TargetJson) WITH(UserId INT, TargetId INT) AS a
                    LEFT JOIN LATargetSetting ls WITH(NOLOCK) ON ls.UserId = a.UserId
               WHERE ISNULL(ls.TargetId, 0) <> ISNULL(a.TargetId, 0);

        -- Update existing records in LATargetSetting
        UPDATE la
          SET 
              TargetId = t.TargetId
        FROM dbo.LATargetSetting la
             INNER JOIN @Temp AS t ON la.UserId = t.UserId;

        -- Insert new records into LATargetSetting
        INSERT INTO dbo.LATargetSetting
        (UserId, 
         TargetId
        )
               SELECT TempTable.UserId, 
                      TempTable.TargetId
               FROM @Temp AS TempTable
               WHERE TempTable.OldTargetId IS NULL;

        -- Write log
        DECLARE @UserId INT= 0, @oldData XML, @newData XML, @EndRun DATETIME, @Duration INT, @NewLogData NVARCHAR(MAX), @OldLogData NVARCHAR(MAX);
        WHILE(1 = 1)
            BEGIN
                DECLARE @Target VARCHAR(20), @OldTarget VARCHAR(20);
                SELECT TOP 1 @UserId = t.UserId, 
                             @Target = rn.Value, 
                             @OldTarget = ro.Value
                FROM @Temp t
                     LEFT JOIN RefResource ro WITH(NOLOCK) ON ro.RefName = 'LaKpiLevel'
                                                              AND ro.ResourceId = t.OldTargetId
                     LEFT JOIN RefResource rn WITH(NOLOCK) ON rn.RefName = 'LaKpiLevel'
                                                              AND rn.ResourceId = t.TargetId
                WHERE UserId > @UserId
                ORDER BY UserId;
                -- break
                IF @@ROWCOUNT = 0
                    BREAK;
                SET @oldData =
                (
                    SELECT ISNULL(@OldTarget, '') '@target' FOR XML PATH('z'), ROOT('r')
                );
                SET @newData =
                (
                    SELECT @Target '@target' FOR XML PATH('z'), ROOT('r')
                );
                SET @OldLogData = REPLACE(CONVERT(NVARCHAR(MAX), @oldData), '" />', '"/"');
                SET @NewLogData = REPLACE(CONVERT(NVARCHAR(MAX), @newData), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                SELECT @OldLogData, 
                       @NewLogData;
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_Kpi_UpdateTargetLevel', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @UserId, 
                     @Data = @NewLogData, 
                     @DataOld = @OldLogData;
            END;
    END;