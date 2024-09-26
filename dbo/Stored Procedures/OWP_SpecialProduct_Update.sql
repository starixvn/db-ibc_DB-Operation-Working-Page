/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Update]
	@ActorId INT 
	,@ProductId INT
	,@Maxbet_FTHDP MONEY
	,@Maxbet_NoOfCorner MONEY = NULL
	,@Spread_NoOfCorner MONEY = NULL
	,@Maxbet_NextCorner MONEY = NULL
	,@Spread_NextCorner MONEY = NULL
	,@Maxbet_10_15Mins MONEY = NULL
	,@Spread_10_15Mins MONEY = NULL
	,@Maxbet_TB MONEY = NULL
	,@Spread_TB MONEY = NULL
	,@Maxbet_NextTB MONEY = NULL
	,@Spread_NextTB MONEY = NULL
	,@Maxbet_PS MONEY = NULL
	,@Spread_PS MONEY = NULL
	,@Maxbet_Winner MONEY = NULL
	,@Spread_Winner MONEY = NULL
	,@Remark NVARCHAR(2000) = NULL
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

	BEGIN
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
			,@OldRemarkLog NVARCHAR(2000)=NULL
			,@NewRemarkLog NVARCHAR(2000)=NULL
			,@ModifyDate DATETIME
			,@ModifyBy INT
			,@ErrorMessage VARCHAR(255) = NULL
	
	SELECT @Maxbet_FTHDPOld=ISNULL(sp.Maxbet_FTHDP,-1)
			,@Maxbet_NoOfCornerOld=ISNULL(sp.Maxbet_NoOfCorner,-1)
			,@Spread_NoOfCornerOld=ISNULL(sp.Spread_NoOfCorner,-1)
			,@Maxbet_NextCornerOld=ISNULL(sp.Maxbet_NextCorner,-1)
			,@Spread_NextCornerOld=ISNULL(sp.Spread_NextCorner,-1)
			,@Maxbet_10_15MinsOld=ISNULL(sp.Maxbet_10_15Mins,-1)
			,@Spread_10_15MinsOld=ISNULL(sp.Spread_10_15Mins,-1)
			,@Maxbet_TBOld=ISNULL(sp.Maxbet_TB,-1)
			,@Spread_TBOld=ISNULL(sp.Spread_TB,-1)
			,@Maxbet_NextTBOld=ISNULL(sp.Maxbet_NextTB,-1)
			,@Spread_NextTBOld=ISNULL(sp.Spread_NextTB,-1)
			,@Maxbet_PSOld=ISNULL(sp.Maxbet_PS,-1)
			,@Spread_PSOld=ISNULL(sp.Spread_PS,-1)
			,@Maxbet_WinnerOld=ISNULL(sp.Maxbet_Winner,-1)
			,@Spread_WinnerOld=ISNULL(sp.Spread_Winner,-1)
			,@RemarkOld=ISNULL(sp.Remark,'')
	FROM SpecialProduct AS sp WITH (NOLOCK)
	WHERE sp.ProductId=@ProductId
	
	SET @Maxbet_FTHDPOld=ISNULL(@Maxbet_FTHDPOld,-1)
	SET @Maxbet_NoOfCornerOld =ISNULL(@Maxbet_NoOfCornerOld,-1)
	SET @Spread_NoOfCornerOld =ISNULL(@Spread_NoOfCornerOld,-1)
	SET @Maxbet_NextCornerOld =ISNULL(@Maxbet_NextCornerOld,-1)
	SET @Spread_NextCornerOld =ISNULL(@Spread_NextCornerOld,-1)
	SET @Maxbet_10_15MinsOld =ISNULL(@Maxbet_10_15MinsOld,-1)
	SET @Spread_10_15MinsOld =ISNULL(@Spread_10_15MinsOld,-1)
	SET @Maxbet_TBOld =ISNULL(@Maxbet_TBOld,-1)
	SET @Spread_TBOld =ISNULL(@Spread_TBOld,-1)
	SET @Maxbet_NextTBOld =ISNULL(@Maxbet_NextTBOld,-1)
	SET @Spread_NextTBOld =ISNULL(@Spread_NextTBOld,-1)
	SET @Maxbet_PSOld =ISNULL(@Maxbet_PSOld,-1)
	SET @Spread_PSOld =ISNULL(@Spread_PSOld,-1)
	SET @Maxbet_WinnerOld =ISNULL(@Maxbet_WinnerOld,-1)
	SET @Spread_WinnerOld =ISNULL(@Spread_WinnerOld,-1)
	SET @RemarkOld =ISNULL(@RemarkOld,'')
	
	DECLARE @Pivot MONEY=-1
	
	---- Check exists @Maxbet_FTHDP
	IF @Maxbet_FTHDPOld<>@Maxbet_FTHDP
	BEGIN
		SELECT @ErrorMessage= 'Duplicate maxbet FTHDP'
		FROM SpecialProduct AS sp WITH (NOLOCK)
		WHERE sp.Maxbet_FTHDP = @Maxbet_FTHDP AND sp.[Type]=@Type
		AND sp.[Type] = @Type
		IF @ErrorMessage IS NOT NULL
		BEGIN
			SELECT @ErrorMessage AS ErrorMessage
				,@ProductId AS ProductId
			RETURN
		END
	END
	
	BEGIN -- ADD/UPDATE PRODUCT
	DECLARE @LastUpdate VARCHAR(255)
	
	SELECT @LastUpdate= u.Username
	FROM [User] AS u WITH (NOLOCK)
	WHERE u.UserId=@ActorId
	
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
	
	SET @Maxbet_FTHDP=ISNULL(@Maxbet_FTHDP,-1)
	SET @Maxbet_NoOfCorner =ISNULL(@Maxbet_NoOfCorner,-1)
	SET @Spread_NoOfCorner =ISNULL(@Spread_NoOfCorner,-1)
	SET @Maxbet_NextCorner =ISNULL(@Maxbet_NextCorner,-1)
	SET @Spread_NextCorner =ISNULL(@Spread_NextCorner,-1)
	SET @Maxbet_10_15Mins =ISNULL(@Maxbet_10_15Mins,-1)
	SET @Spread_10_15Mins =ISNULL(@Spread_10_15Mins,-1)
	SET @Maxbet_TB =ISNULL(@Maxbet_TB,-1)
	SET @Spread_TB =ISNULL(@Spread_TB,-1)
	SET @Maxbet_NextTB =ISNULL(@Maxbet_NextTB,-1)
	SET @Spread_NextTB =ISNULL(@Spread_NextTB,-1)
	SET @Maxbet_PS =ISNULL(@Maxbet_PS,-1)
	SET @Spread_PS =ISNULL(@Spread_PS,-1)
	SET @Maxbet_Winner =ISNULL(@Maxbet_Winner,-1)
	SET @Spread_Winner =ISNULL(@Spread_Winner,-1)
	SET @Remark =ISNULL(@Remark,'')
	
	-- Build log Info
	IF @Maxbet_FTHDPOld<>@Maxbet_FTHDP
	BEGIN
		SET @ProductSetting='Maxbet Of FT.HDP'
		SET @OldValue=CASE WHEN @Maxbet_FTHDPOld<>@Pivot THEN @Maxbet_FTHDPOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_FTHDP<>@Pivot THEN @Maxbet_FTHDP ELSE NULL END
		IF @Maxbet_FTHDPOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_FTHDPOld <> @Pivot AND @Maxbet_FTHDP <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_FTHDP =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_NoOfCornerOld<>@Maxbet_NoOfCorner
	BEGIN
		SET @ProductSetting='Maxbet No.Of Corner'
		SET @OldValue=CASE WHEN @Maxbet_NoOfCornerOld<>@Pivot THEN @Maxbet_NoOfCornerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_NoOfCorner<>@Pivot THEN @Maxbet_NoOfCorner ELSE NULL END
		IF @Maxbet_NoOfCornerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NoOfCornerOld <> @Pivot AND @Maxbet_NoOfCorner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NoOfCorner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_NoOfCornerOld<>@Spread_NoOfCorner
	BEGIN
		SET @ProductSetting='Spread No.Of Corner'
		SET @OldValue=CASE WHEN @Spread_NoOfCornerOld<>@Pivot THEN @Spread_NoOfCornerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_NoOfCorner<>@Pivot THEN @Spread_NoOfCorner ELSE NULL END
		IF @Spread_NoOfCornerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_NoOfCornerOld <> @Pivot AND @Spread_NoOfCorner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_NoOfCorner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_NextCornerOld<>@Maxbet_NextCorner
	BEGIN
		SET @ProductSetting='Maxbet Next Corner'
		SET @OldValue=CASE WHEN @Maxbet_NextCornerOld<>@Pivot THEN @Maxbet_NextCornerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_NextCorner<>@Pivot THEN @Maxbet_NextCorner ELSE NULL END
		IF @Maxbet_NextCornerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NextCornerOld <> @Pivot AND @Maxbet_NextCorner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NextCorner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_NextCornerOld<>@Spread_NextCorner
	BEGIN
		SET @ProductSetting='Spread Next Corner'
		SET @OldValue=CASE WHEN @Spread_NextCornerOld<>@Pivot THEN @Spread_NextCornerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_NextCorner<>@Pivot THEN @Spread_NextCorner ELSE NULL END
		IF @Spread_NextCornerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_NextCornerOld <> @Pivot AND @Spread_NextCorner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_NextCorner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_10_15MinsOld<>@Maxbet_10_15Mins
	BEGIN
		SET @ProductSetting='Maxbet 10-15 mins'
		SET @OldValue=CASE WHEN @Maxbet_10_15MinsOld<>@Pivot THEN @Maxbet_10_15MinsOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_10_15Mins<>@Pivot THEN @Maxbet_10_15Mins ELSE NULL END
		IF @Maxbet_10_15MinsOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_10_15MinsOld <> @Pivot AND @Maxbet_10_15Mins <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_10_15Mins =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_10_15MinsOld<>@Spread_10_15Mins
	BEGIN
		SET @ProductSetting='Spread 10-15 mins'
		SET @OldValue=CASE WHEN @Spread_10_15MinsOld<>@Pivot THEN @Spread_10_15MinsOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_10_15Mins<>@Pivot THEN @Spread_10_15Mins ELSE NULL END
		IF @Spread_10_15MinsOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_10_15MinsOld <> @Pivot AND @Spread_10_15Mins <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_10_15Mins =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_TBOld<>@Maxbet_TB
	BEGIN
		SET @ProductSetting='Maxbet Total Booking'
		SET @OldValue=CASE WHEN @Maxbet_TBOld<>@Pivot THEN @Maxbet_TBOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_TB<>@Pivot THEN @Maxbet_TB ELSE NULL END
		IF @Maxbet_TBOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_TBOld <> @Pivot AND @Maxbet_TB <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_TB =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_TBOld<>@Spread_TB
	BEGIN
		SET @ProductSetting='Spread Total Booking'
		SET @OldValue=CASE WHEN @Spread_TBOld<>@Pivot THEN @Spread_TBOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_TB<>@Pivot THEN @Spread_TB ELSE NULL END
		IF @Spread_TBOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_TBOld <> @Pivot AND @Spread_TB <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_TB =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_NextTBOld<>@Maxbet_NextTB
	BEGIN
		SET @ProductSetting='Maxbet of Next Booking'
		SET @OldValue=CASE WHEN @Maxbet_NextTBOld<>@Pivot THEN @Maxbet_NextTBOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_NextTB<>@Pivot THEN @Maxbet_NextTB ELSE NULL END
		IF @Maxbet_NextTBOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_NextTBOld <> @Pivot AND @Maxbet_NextTB <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_NextTB =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_NextTBOld<>@Spread_NextTB
	BEGIN
		SET @ProductSetting='Spread of Next Booking'
		SET @OldValue=CASE WHEN @Spread_NextTBOld<>@Pivot THEN @Spread_NextTBOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_NextTB<>@Pivot THEN @Spread_NextTB ELSE NULL END
		IF @Spread_NextTBOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_NextTBOld <> @Pivot AND @Spread_NextTB <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_NextTB =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_PSOld<>@Maxbet_PS
	BEGIN
		SET @ProductSetting='Maxbet of Penalty Shootout'
		SET @OldValue=CASE WHEN @Maxbet_PSOld<>@Pivot THEN @Maxbet_PSOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_PS<>@Pivot THEN @Maxbet_PS ELSE NULL END
		IF @Maxbet_PSOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_PSOld <> @Pivot AND @Maxbet_PS <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_PS =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_PSOld<>@Spread_PS
	BEGIN
		SET @ProductSetting='Spread of Penalty Shootout'
		SET @OldValue=CASE WHEN @Spread_PSOld<>@Pivot THEN @Spread_PSOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_PS<>@Pivot THEN @Spread_PS ELSE NULL END
		IF @Spread_PSOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_PSOld <> @Pivot AND @Spread_PS <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_PS =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Maxbet_WinnerOld<>@Maxbet_Winner
	BEGIN
		SET @ProductSetting='Maxbet of Winner'
		SET @OldValue=CASE WHEN @Maxbet_WinnerOld<>@Pivot THEN @Maxbet_WinnerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Maxbet_Winner<>@Pivot THEN @Maxbet_Winner ELSE NULL END
		IF @Maxbet_WinnerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Maxbet_WinnerOld <> @Pivot AND @Maxbet_Winner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Maxbet_Winner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	------------------------
	IF @Spread_WinnerOld<>@Spread_Winner
	BEGIN
		SET @ProductSetting='Spread of Winner'
		SET @OldValue=CASE WHEN @Spread_WinnerOld<>@Pivot THEN @Spread_WinnerOld ELSE NULL END
		SET @NewValue=CASE WHEN @Spread_Winner<>@Pivot THEN @Spread_Winner ELSE NULL END
		IF @Spread_WinnerOld =@Pivot
		BEGIN
			SET @Action=1
		END
		IF @Spread_WinnerOld <> @Pivot AND @Spread_Winner <> @Pivot
		BEGIN
			SET @Action=2
		END
		IF @Spread_Winner =@Pivot
		BEGIN
			SET @Action=3
		END
	END
	
	IF @RemarkOld<>@Remark
	BEGIN
		SET @ProductSetting='Remark'
		SET @OldRemarkLog=CASE WHEN @RemarkOld<>'' THEN @RemarkOld ELSE NULL END
		SET @NewRemarkLog=CASE WHEN @Remark<>'' THEN @Remark ELSE NULL END
		IF @RemarkOld =''
		BEGIN
			SET @Action=1
		END
		IF @RemarkOld <> '' AND @Remark <> ''
		BEGIN
			SET @Action=2
		END
		IF @Remark =''
		BEGIN
			SET @Action=3
		END
	END
	
	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML=NULL

	SET @StartRun = GETDATE()
	-- Old data
	SET @Xml = CASE
				WHEN @Action<>1 THEN (
					SELECT @ProductSetting AS '@p'
						,(CASE
							WHEN @ProductSetting='Remark' THEN @OldRemarkLog
							ELSE LTRIM(RTRIM(STR(@OldValue,19,4)))
						END) AS '@vl'
					FOR XML PATH('z')
						,ROOT('r')
					)
				ELSE NULL
			END
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	--New data
	SET @Xml = CASE
				WHEN @Action<>3 THEN(
			SELECT @ProductSetting AS '@p'
				,(CASE
					WHEN @ProductSetting='Remark' THEN @NewRemarkLog
					ELSE LTRIM(RTRIM(STR(@NewValue,19,4)))
				END) AS '@vl'
			FOR XML PATH('z')
				,ROOT('r')
			)
			ELSE NULL
		END

	SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @EndRun = GETDATE()
	SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)
	
	DECLARE @SPName NVARCHAR(128)
	SET @SPName=CASE
					WHEN @Action=1 THEN 'OWP_SpecialProductInsert'
					WHEN @Action=2 THEN 'OWP_SpecialProductUpdate'
					WHEN @Action=3 THEN 'OWP_SpecialProductDelete'
					ELSE NULL
				END
	IF @ProductId = -1
	BEGIN
		SELECT @ProductId = MAX(sp.ProductId)
		FROM SpecialProduct AS sp WITH (NOLOCK)
	END

	EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
		,@SPName = @SPName
		,@LoggedDate = @StartRun
		,@Duration = @Duration
		,@ObjectId = @ProductId
		,@Data = @LogData
		,@DataOld = @LogDataOld
	END -- END WRITE LOG
	
	SELECT @ProductId AS ProductId,
		@ErrorMessage
END