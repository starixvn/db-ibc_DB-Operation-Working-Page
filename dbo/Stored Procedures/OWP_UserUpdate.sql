
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserUpdate] @ActorId INT
	,@UserId INT
	,@ColumnName NVARCHAR(200) = NULL
	,@Value VARCHAR(500) = NULL
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170119@Julien
Task : User Management
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20181120@Kane.Le: Update Pickup, Address, Level, Refactor SP  [Redmine: #105043]
	20190402@Kane.Le: Update IsSecondAccount - [Redmine: #11068]	
	20191014@Kane.Le: Update user per column - [Redmine: #121765]

*/
BEGIN
	SET NOCOUNT ON

	IF ISNULL(@ColumnName, '') = ''
		AND ISNULL(@Value, '') = ''
	BEGIN
		RETURN;
	END

	IF NOT EXISTS (
			SELECT u.UserId
			FROM dbo.[User] u WITH (NOLOCK)
			WHERE u.UserId = @UserId
			)
	BEGIN
		SELECT @ErrMsg = 'User ID is invalid!'
			,@ErrCode = 5801 -- ActionId + 01

		RETURN
	END

	IF @ColumnName = 'NickName'
	BEGIN
		IF EXISTS (
				SELECT TOP 1 u.UserId
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.UserId <> @UserId
					AND (
						u.Nickname = @Value
						OR u.Username = @Value
						)
				)
		BEGIN
			SELECT @ErrMsg = 'Nickname already exists!'
				,@ErrCode = 5802

			RETURN
		END
	END

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	SET @StartRun = GETDATE()

	--Old Data
	/*
		SET @Xml = (
				SELECT ISNULL(ou.FullName, '') AS '@fn'
					,ISNULL(ou.NickName, '') AS '@nn'
					,ISNULL(ou.EmployeeId, '') AS '@eid'
					,ISNULL(ou.CategoryId, 0) AS '@ca'
					,ISNULL(ou.Extension, '') AS '@ex'
					,ISNULL(ou.Phone, '') AS '@p'
					,ISNULL(ou.Email, '') AS '@e'
					,ISNULL(ou.Skype, '') AS '@s'
					,ISNULL(ou.DepartmentId, 0) AS '@d'
					,ISNULL(ou.SectionId, 0) AS '@sec'
					,ISNULL(ou.GroupId, 0) AS '@grp'
					,ISNULL(ur.RoleId, 0) AS '@r'
					,ISNULL(ou.LocationCode, '') AS '@lo'
					,ISNULL(ou.Pickup, '') AS '@pk'
					,ISNULL(ou.[Address], '') AS '@ad'
					,ISNULL(ou.[Level], '') AS '@lv'
					,ISNULL(ou.[IsSecondAccount], '') AS '@sa'
				FROM [User] ou WITH (NOLOCK)
				LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = ou.UserId
				WHERE ou.UserId = @UserId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		*/
	--Update
	IF @ColumnName = 'EmployeeId'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK) SET EmployeeId = @Value WHERE UserId = @UserId
	END
	IF @ColumnName = 'FullName'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK, ROWLOCK) SET FullName = @Value	WHERE UserId = @UserId
	END
	IF @ColumnName = 'NickName'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET NickName = @Value WHERE UserId = @UserId
	END
	IF @ColumnName = 'DepartmentId'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET DepartmentId = CAST(@Value AS INT) WHERE UserId = @UserId
	END
	IF @ColumnName = 'SectionId'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET SectionId = CAST(@Value AS INT) WHERE UserId = @UserId
	END
	IF @ColumnName = 'GroupId'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET GroupId = CAST(@Value AS INT) WHERE UserId = @UserId
	END

	IF @ColumnName = 'Extension'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Extension = @Value  WHERE UserId = @UserId
	END

	IF @ColumnName = 'Phone'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Phone = @Value  WHERE UserId = @UserId
	END
	IF @ColumnName = 'Email'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Email = @Value  WHERE UserId = @UserId
	END
	IF @ColumnName = 'Skype'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Skype = @Value  WHERE UserId = @UserId
	END
	IF @ColumnName = 'CategoryId'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET CategoryId = CAST(@Value AS INT)  WHERE UserId = @UserId
	END
	IF @ColumnName = 'LocationCode'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET LocationCode = @Value  WHERE UserId = @UserId
	END
	IF @ColumnName = 'Pickup'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Pickup = CAST(@Value AS BIT)  WHERE UserId = @UserId
	END
	IF @ColumnName = 'Level'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET [Level] = CAST(@Value AS INT)  WHERE UserId = @UserId
	END
	IF @ColumnName = 'Address'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET Address = @Value  WHERE UserId = @UserId
	END
	IF @ColumnName = 'IsSecondAccount'
	BEGIN
		UPDATE dbo.[User] WITH (UPDLOCK	,ROWLOCK ) SET IsSecondAccount = CAST(@Value AS BIT)  WHERE UserId = @UserId
	END
	IF (
			@ColumnName = 'RoleId'
			AND @Value IS NOT NULL
			)
	BEGIN
		DELETE
		FROM dbo.UserRole
		WHERE UserId = @UserId

		INSERT INTO dbo.UserRole (
			UserId
			,RoleId
			)
		VALUES (
			@UserId
			, CAST(@Value AS INT)
			)
	END
			--New data
			/*
		SET @Xml = (
				SELECT ISNULL(@FullName, '') AS '@fn'
					,ISNULL(@NickName, '') AS '@nn'
					,ISNULL(@EmployeeId, '') AS '@eid'
					,ISNULL(@CategoryId, 0) AS '@ca'
					,ISNULL(@Extension, '') AS '@ex'
					,ISNULL(@Phone, '') AS '@p'
					,ISNULL(@Email, '') AS '@e'
					,ISNULL(@Skype, '') AS '@s'
					,ISNULL(@DepartmentId, 0) AS '@d'
					,ISNULL(@SectionId, 0) AS '@sec'
					,ISNULL(@GroupId, 0) AS '@grp'
					,ISNULL(@RoleId, 0) AS '@r'
					,ISNULL(@LocationCode, '') AS '@lo'
					,ISNULL(@Pickup, '') AS '@pk'
					,ISNULL(@Address, '') AS '@ad'
					,ISNULL(@Level, '') AS '@lv'
					,ISNULL(@IsSecondAccount, '') AS '@sa'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)
		 
		EXEC dbo.OWP_WriteLog @CreatorId = @ActorId
			,@SPName = 'OWP_UserUpdate'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @UserId
			,@Data = @LogData
			,@DataOld = @LogDataOld
			*/
END