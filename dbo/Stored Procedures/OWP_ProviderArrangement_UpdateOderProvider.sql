
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderArrangement_UpdateOderProvider] @Providers NVARCHAR(MAX), 
                                                                   @ActorId   INT
AS

/*
Created: 20220106@Johnny
Task : Edit provider arrangement
DB: bodb_OWP

Revisions:
	20220106@Johnny: Initial - [Redmine: #181896]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (Id      INT, 
         [Value] NVARCHAR(MAX), 
         [Order] INT
        );
        DECLARE @OldData TABLE
        (RowNumber INT, 
         [Value]   NVARCHAR(MAX)
        );
        DECLARE @NewData TABLE
        (RowNumber INT, 
         [Value]   NVARCHAR(MAX)
        );
        INSERT INTO @Temp
        (Id, 
         [Value], 
         [Order]
        )
               SELECT Id, 
                      [Value], 
                      [Order]
               FROM OPENJSON(@Providers) WITH(Id INT, [Value] NVARCHAR(MAX), [Order] INT);
        INSERT INTO @OldData
        (RowNumber, 
         [Value]
        )
               SELECT ROW_NUMBER() OVER(
                      ORDER BY p.[Order]) AS RowNumber, 
                      p.[Value]
               FROM dbo.ProviderArrangement p;
        INSERT INTO @NewData
        (RowNumber, 
         [Value]
        )
               SELECT ROW_NUMBER() OVER(
                      ORDER BY t.[Order]) AS RowNumber, 
                      t.[Value]
               FROM @Temp t;
        --Write log
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX), @ActionName NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        SET @ActionName = 'Update the provider order table';
        SET @XmlLogOld =
        (
            SELECT STRING_AGG(oldLog.[Value], ',') '@lProvider', 
                   @ActionName '@lActionName'
            FROM @OldData AS oldLog FOR XML PATH('z'), ROOT('r')
        );
        SET @XmlLogNew =
        (
            SELECT STRING_AGG(newLog.[Value], ',') '@lProvider', 
                   @ActionName '@lActionName'
            FROM @NewData AS newLog FOR XML PATH('z'), ROOT('r')
        );
        SET @LogNew = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogNew), '" />', '"/"');
        SET @LogOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogOld), '" />', '"/"');

        --Update
        UPDATE p
          SET 
              p.[Order] = t.[Order]
        FROM dbo.ProviderArrangement p, @Temp t
        WHERE p.Id = t.Id;
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_ProviderArrangement_UpdateOderProvider', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @Data = @LogNew, 
             @DataOld = @LogOld;
    END;