
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderArrangement_UpdateOderProvider] @Providers NVARCHAR(MAX), 
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
        INSERT INTO @Temp
        (Id, 
         [Value], 
         [Order]
        )
               SELECT Id, 
                      [Value], 
                      [Order]
               FROM OPENJSON(@Providers) WITH(Id INT, [Value] NVARCHAR(MAX), [Order] INT);

        --Write log
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX);
        DECLARE @Log TABLE
        (OldValue NVARCHAR(MAX), 
         NewValue NVARCHAR(MAX)
        );
        SET @StartRun = GETDATE();
        INSERT INTO @Log
        (OldValue, 
         NewValue
        )
               SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), ISNULL(p.[Value], 'N/A')), ','), 
                      STRING_AGG(CONVERT(NVARCHAR(MAX), ISNULL(t.[Value], 'N/A')), ',')
               FROM dbo.ProviderArrangement p, 
                    @Temp t;
        SET @XmlLogOld =
        (
            SELECT OldValue
            FROM @Log FOR XML PATH('z'), ROOT('r')
        );
        SET @XmlLogNew =
        (
            SELECT NewValue
            FROM @Log FOR XML PATH('z'), ROOT('r')
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