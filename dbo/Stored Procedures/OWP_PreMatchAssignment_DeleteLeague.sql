
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteLeague] @ActorId    INT, 
                                                            @PreMatchLeagueId INT
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
        DECLARE @StartRun DATETIME= GETDATE(), @EndRun DATETIME, @Duration INT, @LogDataOld NVARCHAR(MAX), @Xml XML;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.[PreMatchLeague] WITH(NOLOCK)
            WHERE PreMatchLeagueId = @PreMatchLeagueId
                  AND IsDeleted = 0
        )
            BEGIN
                UPDATE dbo.[PreMatchLeague] WITH(ROWLOCK)
                  SET 
                      IsDeleted = 1
                WHERE PreMatchLeagueId = @PreMatchLeagueId;
                SET @Xml =
                (
                    SELECT @PreMatchLeagueId AS '@plid' FOR XML PATH('z'), ROOT('r')
                );
                SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"');
                SET @EndRun = GETDATE();
                SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_PreMatchAssignment_DeleteLeague', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @PreMatchLeagueId, 
                     @DataOld = @LogDataOld;
        END;
    END;