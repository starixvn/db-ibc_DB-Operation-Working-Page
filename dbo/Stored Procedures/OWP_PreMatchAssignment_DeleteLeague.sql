
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteLeague] @ActorId    INT, 
                                                            @DeletedIds NVARCHAR(MAX) = ''
AS

/*
Created: 20200817@Tyler
Task : Delete Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        CREATE TABLE #deleteIds
        (RowId            INT IDENTITY(1, 1), 
         PreMatchLeagueId INT
        );
        DECLARE @i INT= 1;
        DECLARE @totalLeague INT;

        INSERT INTO #deleteIds(PreMatchLeagueId)
               SELECT [Value]
               FROM dbo.fnc_SplitString(@DeletedIds, ',');

        SELECT @totalLeague = COUNT(RowId)
        FROM #deleteIds;

        WHILE @i <= @totalLeague
            BEGIN
                DECLARE @preMatchLeagueId INT;
                DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @Xml XML;

                SELECT @preMatchLeagueId = (PreMatchLeagueId)
                FROM #deleteIds
                WHERE RowId = @i;

                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.[PreMatchLeague] WITH(NOLOCK)
                    WHERE PreMatchLeagueId = @preMatchLeagueId
                          AND IsDeleted = 0
                )
                    BEGIN
                        UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
                          SET 
                              IsDeleted = 1
                        WHERE PreMatchLeagueId = @preMatchLeagueId;
                        SET @Xml =
                        (
                            SELECT @preMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r')
                        );
                        SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                        SET @EndRun = GETDATE();
                        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                        EXEC dbo.OWP_WriteLog 
                             @CreatorId = @ActorId, 
                             @SPName = 'OWP_PreMatchAssignment_DeleteLeague', 
                             @LoggedDate = @StartRun, 
                             @Duration = @Duration, 
                             @ObjectId = @preMatchLeagueId, 
                             @DataOld = @LogDataOld;
                END;

                SET @i = @i + 1;
            END;
        DROP TABLE #deleteIds;
    END;