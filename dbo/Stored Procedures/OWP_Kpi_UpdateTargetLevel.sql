
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Kpi_UpdateTargetLevel] @TargetJson NVARCHAR(MAX)
AS

/*
Created: 20230918@Mira
Task : LA KPI phase 2
DB: bodb_OWP	

Revisions:
	20230918@Mira: add table setting for LA level - [Redmine: #193488]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (UserId   INT NOT NULL, 
         TargetId INT
        );
        INSERT INTO @Temp
        (UserId, 
         TargetId
        )
               SELECT UserId, 
                      TargetId
               FROM OPENJSON(@TargetJson) WITH(UserId INT, TargetId INT);

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
               WHERE NOT EXISTS
               (
                   SELECT 1
                   FROM LATargetSetting AS Existing
                   WHERE Existing.UserId = TempTable.UserId
               );
    END;