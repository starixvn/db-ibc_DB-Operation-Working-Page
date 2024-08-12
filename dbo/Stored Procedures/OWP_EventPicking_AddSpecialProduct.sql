
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_AddSpecialProduct]	@ParentId       VARCHAR(MAX), 
															@MinorBettypeId VARCHAR(MAX), 
															@ActorId        INT
AS

/*      
 Created: 20240809@Johnny
 Task : Add special product
 DB: bodb_OWP      
 
 Revisions:
    20240809@Johnny: Init sp  - [Redmine: #207942]

*/

    BEGIN
        SET NOCOUNT ON;

		DECLARE @parentIdWithMinorBettypeId TABLE
		(
		 ParentMatchId  INT, 
         MinorBettypeId INT
		);
		
        DECLARE @tempAdd TABLE
        (Id             INT IDENTITY(1, 1), 
         ParentMatchId  INT, 
         MinorBettypeId INT, 
         NoOfHDP        MONEY, 
         MaxbetHDP      MONEY, 
         SpreadHDP      MONEY, 
         SpreadOU       MONEY
        );

		INSERT INTO @parentIdWithMinorBettypeId (ParentMatchId, MinorBettypeId)
		SELECT p.[value], m.[value]
		FROM STRING_SPLIT(@ParentId, ',') AS p
		CROSS JOIN STRING_SPLIT(@MinorBettypeId, ',') AS m;

		INSERT INTO @tempAdd(ParentMatchId, MinorBettypeId, NoOfHDP, MaxbetHDP, SpreadHDP, SpreadOU)
		SELECT pa.ParentMatchId,
			   pa.MinorBettypeId,
			   NULL,
			   NULL,
			   NULL,
			   NULL
		FROM   @parentIdWithMinorBettypeId AS pa
		WHERE  pa.ParentMatchId IN (SELECT e.ParentId FROM EventPickingChildMatch e) 
		AND    pa.MinorBettypeId NOT IN(SELECT e.MinorBettypeId FROM EventPickingChildMatch e WHERE e.ParentId = pa.ParentMatchId)
		UNION
		SELECT pa.ParentMatchId,
			   pa.MinorBettypeId,
			   NULL,
			   NULL,
			   NULL,
			   NULL
		FROM   @parentIdWithMinorBettypeId AS pa
		LEFT   JOIN EventPickingChildMatch AS e WITH(NOLOCK) ON pa.ParentMatchId != e.ParentId
		WHERE  pa.ParentMatchId NOT IN (SELECT e.ParentId FROM EventPickingChildMatch e)
		INSERT INTO EventPickingChildMatch(ParentId, MinorBettypeId, NoOfHDP, MaxbetHDP, SpreadHDP, SpreadOU)
		SELECT ParentMatchId,
			   MinorBettypeId,
			   NoOfHDP,
			   MaxbetHDP,
			   SpreadHDP,
			   SpreadOU
		FROM   @tempAdd
		-- Log the operation
		DECLARE @StartRun DATETIME = GETDATE();
		DECLARE @LogSettingDataOld NVARCHAR(MAX);
		DECLARE @Duration INT;
		-- Prepare log data
		SET @LogSettingDataOld = (
			SELECT ParentMatchId, MinorBettypeId, NoOfHDP, MaxbetHDP, SpreadHDP, SpreadOU
			FROM @tempAdd
			FOR XML PATH('z'), ROOT('r')
		);

		SET @LogSettingDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @LogSettingDataOld), '" />', '"/"');
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, GETDATE());

		-- Write log
		EXEC dbo.OWP_WriteLog 
			@CreatorId = @ActorId, 
			@SPName = 'OWP_EventPicking_AddSpecialProduct', 
			@LoggedDate = @StartRun, 
			@Duration = @Duration, 
			@ObjectId = 1000, 
			@Data = NULL, 
			@DataOld = @LogSettingDataOld;
    END;