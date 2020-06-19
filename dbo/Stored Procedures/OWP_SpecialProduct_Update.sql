/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Update]
	@ActorId INT
	,@ProductId INT
	,@Maxbet_FTHDP MONEY
	,@Maxbet_NoOfCorner MONEY
	,@Spread_NoOfCorner MONEY
	,@Maxbet_NextCorner MONEY
	,@Spread_NextCorner MONEY
	,@Maxbet_10_15Mins MONEY
	,@Spread_10_15Mins MONEY
	,@Maxbet_TB MONEY
	,@Spread_TB MONEY
	,@Maxbet_NextTB MONEY
	,@Spread_NextTB MONEY
	,@Maxbet_PS MONEY
	,@Spread_PS MONEY
	,@Maxbet_Winner MONEY
	,@Spread_Winner MONEY
	,@Remark NVARCHAR(2000)
	,@Type VARCHAR(10)
AS
/*
Created: 20180617@Carlos.Nguyen
Task : update Special Product
DB: bodb_OWP

Revisions:
	20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
*/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @LastUpdate VARCHAR(255)
	
	SELECT @LastUpdate= u.Username
	FROM [User] AS u WITH (NOLOCK)
	WHERE u.UserId=@ActorId
	
	
	BEGIN -- ADD/UPDATE PRODUCT
	IF @ProductId=-1
	BEGIN -- ADD new product
		INSERT INTO SpecialProduct
		(
			Maxbet_FTHDP
			,Maxbet_NoOfCorner
			,Spread_NoOfCorner 
			,Maxbet_NextCorner 
			,Spread_NextCorner
			,Maxbet_10_15Mins 
			,Spread_10_15Mins 
			,Maxbet_TB 
			,Spread_TB 
			,Maxbet_NextTB
			,Spread_NextTB 
			,Maxbet_PS 
			,Spread_PS 
			,Maxbet_Winner
			,Spread_Winner 
			,Remark
			,LastUpdate
			,[Type]
		)
		VALUES(@Maxbet_FTHDP
			,@Maxbet_NoOfCorner
			,@Spread_NoOfCorner
			,@Maxbet_NextCorner
			,@Spread_NextCorner 
			,@Maxbet_10_15Mins 
			,@Spread_10_15Mins
			,@Maxbet_TB 
			,@Spread_TB
			,@Maxbet_NextTB
			,@Spread_NextTB 
			,@Maxbet_PS 
			,@Spread_PS 
			,@Maxbet_Winner
			,@Spread_Winner 
			,@Remark
			,@LastUpdate
			,@Type
		)
		
		SELECT @ProductId=MAX(sp.ProductId)
		FROM SpecialProduct AS sp WITH (NOLOCK)
	END
	ELSE
	BEGIN -- UPDATE PRODUCT
		UPDATE SpecialProduct
		SET
			Maxbet_FTHDP=@Maxbet_FTHDP
			,Maxbet_NoOfCorner=@Maxbet_NoOfCorner
			,Spread_NoOfCorner =@Spread_NoOfCorner
			,Maxbet_NextCorner =@Maxbet_NextCorner
			,Spread_NextCorner =@Spread_NextCorner
			,Maxbet_10_15Mins =@Maxbet_10_15Mins
			,Spread_10_15Mins =@Spread_10_15Mins
			,Maxbet_TB =@Maxbet_TB
			,Spread_TB =@Spread_TB
			,Maxbet_NextTB=@Maxbet_NextTB
			,Spread_NextTB =@Spread_NextTB
			,Maxbet_PS =@Maxbet_PS
			,Spread_PS =@Spread_PS
			,Maxbet_Winner=@Maxbet_Winner
			,Spread_Winner =@Spread_Winner
			,Remark =@Remark
			,LastUpdate=@LastUpdate
			,[Type]=@Type
		WHERE ProductId=@ProductId
	END
	END -- END ADD/UPDATE PRODUCT
	
	BEGIN-- WRITE LOG
	-- Declare variable old data
	DECLARE @Maxbet_FTHDPOld MONEY
			,@Maxbet_NoOfCornerOld MONEY
			,@Spread_NoOfCornerOld MONEY
			,@Maxbet_NextCornerOld MONEY
			,@Spread_NextCornerOld MONEY
			,@Maxbet_10_15MinsOld MONEY 
			,@Spread_10_15MinsOld MONEY 
			,@Maxbet_TBOld MONEY 
			,@Spread_TBOld MONEY 
			,@Maxbet_NextTBOld MONEY
			,@Spread_NextTBOld MONEY 
			,@Maxbet_PSOld MONEY 
			,@Spread_PSOld MONEY 
			,@Maxbet_WinnerOld MONEY
			,@Spread_WinnerOld MONEY 
			,@RemarkOld NVARCHAR(2000)
			,@ProductSetting VARCHAR(255)
			,@Action INT
			,@OldValue MONEY
			,@NewValue MONEY
			,@ModifyDate DATETIME
			,@ModifyBy INT
	
	SELECT @Maxbet_FTHDPOld=sp.Maxbet_FTHDP
			,@Maxbet_NoOfCornerOld=sp.Maxbet_NoOfCorner
			,@Spread_NoOfCornerOld=sp.Spread_NoOfCorner
			,@Maxbet_NextCornerOld=sp.Maxbet_NextCorner
			,@Spread_NextCornerOld=sp.Spread_NextCorner
			,@Maxbet_10_15MinsOld=sp.Maxbet_10_15Mins
			,@Spread_10_15MinsOld=sp.Spread_10_15Mins
			,@Maxbet_TBOld=sp.Maxbet_TB
			,@Spread_TBOld=sp.Spread_TB
			,@Maxbet_NextTBOld=sp.Maxbet_NextTB
			,@Spread_NextTBOld=sp.Spread_NextTB
			,@Maxbet_PSOld=sp.Maxbet_PS
			,@Spread_PSOld=sp.Spread_PS
			,@Maxbet_WinnerOld=sp.Maxbet_Winner
			,@Spread_WinnerOld=sp.Spread_Winner
			,@RemarkOld=sp.Remark
	FROM SpecialProduct AS sp WITH (NOLOCK)
	WHERE sp.ProductId=@ProductId
	

	IF @Maxbet_FTHDPOld<>@Maxbet_FTHDP
	BEGIN
		SET @ProductSetting='Maxbet Of FT.HDP'
		SET @OldValue=@Maxbet_FTHDPOld
		SET @NewValue=@Maxbet_FTHDP
		IF @Maxbet_FTHDPOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_FTHDPOld IS NOT NULL AND @Maxbet_FTHDP IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_FTHDP IS NULL
		BEGIN
			SET @Action=3
		END
	END
		
	IF @Maxbet_NoOfCornerOld<>@Maxbet_NoOfCorner
	BEGIN
		SET @ProductSetting='Maxbet No.Of Corner'
		SET @OldValue=@Maxbet_NoOfCornerOld
		SET @NewValue=@Maxbet_NoOfCorner
		IF @Maxbet_NoOfCornerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NoOfCornerOld IS NOT NULL AND @Maxbet_NoOfCorner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NoOfCorner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_NoOfCornerOld<>@Spread_NoOfCorner
	BEGIN
		SET @ProductSetting='Spread No.Of Corner'
		SET @OldValue=@Spread_NoOfCornerOld
		SET @NewValue=@Spread_NoOfCorner
		IF @Spread_NoOfCornerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_NoOfCornerOld IS NOT NULL AND @Spread_NoOfCorner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_NoOfCorner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_NextCornerOld<>@Maxbet_NextCorner
	BEGIN
		SET @ProductSetting='Spread Next Corner'
		SET @OldValue=@Maxbet_NextCornerOld
		SET @NewValue=@Maxbet_NextCorner
		IF @Maxbet_NextCornerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NextCornerOld IS NOT NULL AND @Maxbet_NextCorner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NextCorner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	---------------------
	IF @Spread_NextCornerOld<>@Spread_NextCorner
	BEGIN
		SET @ProductSetting='Spread Next Corner'
		SET @OldValue=@Spread_NextCornerOld
		SET @NewValue=@Spread_NextCorner
		IF @Spread_NextCornerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_NextCornerOld IS NOT NULL AND @Spread_NextCorner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_NextCorner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_10_15MinsOld<>@Maxbet_10_15Mins
	BEGIN
		SET @ProductSetting='Maxbet 10-15 mins'
		SET @OldValue=@Maxbet_10_15MinsOld
		SET @NewValue=@Maxbet_10_15Mins
		IF @Maxbet_10_15MinsOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_10_15MinsOld IS NOT NULL AND @Maxbet_10_15Mins IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_10_15Mins IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_10_15MinsOld<>@Spread_10_15Mins
	BEGIN
		SET @ProductSetting='Spread 10-15 mins'
		SET @OldValue=@Spread_10_15MinsOld
		SET @NewValue=@Spread_10_15Mins
		IF @Spread_10_15MinsOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_10_15MinsOld IS NOT NULL AND @Spread_10_15Mins IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_10_15Mins IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_TBOld<>@Maxbet_TB
	BEGIN
		SET @ProductSetting='Maxbet Total Booking'
		SET @OldValue=@Maxbet_TBOld
		SET @NewValue=@Maxbet_TB
		IF @Maxbet_TBOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_TBOld IS NOT NULL AND @Maxbet_TB IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_TB IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_TBOld<>@Spread_TB
	BEGIN
		SET @ProductSetting='Spread Total Booking'
		SET @OldValue=@Spread_TBOld
		SET @NewValue=@Spread_TB
		IF @Spread_TBOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_TBOld IS NOT NULL AND @Spread_TB IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_TB IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_NextTBOld<>@Maxbet_NextTB
	BEGIN
		SET @ProductSetting='Maxbet of Next Total Booking'
		SET @OldValue=@Maxbet_NextTBOld
		SET @NewValue=@Maxbet_NextTB
		IF @Maxbet_NextTBOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NextTBOld IS NOT NULL AND @Maxbet_NextTB IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NextTB IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_NextTBOld<>@Spread_NextTB
	BEGIN
		SET @ProductSetting='Spread of Next Total Booking'
		SET @OldValue=@Spread_NextTBOld
		SET @NewValue=@Spread_NextTB
		IF @Spread_NextTBOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_NextTBOld IS NOT NULL AND @Spread_NextTB IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_NextTB IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_PSOld<>@Maxbet_PS
	BEGIN
		SET @ProductSetting='Maxbet of Penalty Shootout'
		SET @OldValue=@Maxbet_PSOld
		SET @NewValue=@Maxbet_PS
		IF @Maxbet_PSOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_PSOld IS NOT NULL AND @Maxbet_PS IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_PS IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_PSOld<>@Spread_PS
	BEGIN
		SET @ProductSetting='Spread of Penalty Shootout'
		SET @OldValue=@Spread_PSOld
		SET @NewValue=@Spread_PS
		IF @Spread_PSOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_PSOld IS NOT NULL AND @Spread_PS IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_PS IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Maxbet_WinnerOld<>@Maxbet_Winner
	BEGIN
		SET @ProductSetting='MB of Winner'
		SET @OldValue=@Maxbet_WinnerOld
		SET @NewValue=@Maxbet_Winner
		IF @Maxbet_WinnerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_WinnerOld IS NOT NULL AND @Maxbet_Winner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_Winner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	IF @Spread_WinnerOld<>@Spread_Winner
	BEGIN
		SET @ProductSetting='Spread of Winner'
		SET @OldValue=@Spread_WinnerOld
		SET @NewValue=@Spread_Winner
		IF @Spread_WinnerOld IS NULL
		BEGIN
			SET @Action=1
		END
		IF @Spread_WinnerOld IS NOT NULL AND @Spread_Winner IS NOT NULL
		BEGIN
			SET @Action=2
		END
		IF @Spread_Winner IS NULL
		BEGIN
			SET @Action=3
		END
	END
	
	--IF @RemarkOld<>@Remark
	--BEGIN
	--	IF @RemarkOld IS NULL
	--	BEGIN
	--		SET @ProductSetting='MB of FT.HDP'
	--		SET @Action=1
	--	END
	--	IF @Maxbet_FTHDP IS NULL
	--	BEGIN
	--		SET @ProductSetting='MB of FT.HDP'
	--		SET @Action=2
	--	END
	--	IF @Maxbet_FTHDPOld<>@Maxbet_FTHDP
	--	BEGIN
	--		SET @ProductSetting='MB of FT.HDP'
	--		SET @Action=3
	--	END
	--END
	
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()
	-- Old data
	SET @Xml = (
			SELECT @ProductSetting AS '@p'
				,@OldValue AS '@vl'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	--New data
	SET @Xml = (
			SELECT @ProductSetting AS '@p'
				,@NewValue AS '@vl'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = 'OWP_MatchSetting_Update'
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ProductId
		,@Data = @LogData
		,@DataOld = @LogDataOld
	END -- END WRITE LOG
	
	SELECT @ProductId
END