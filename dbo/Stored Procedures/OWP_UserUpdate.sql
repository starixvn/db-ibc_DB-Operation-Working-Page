
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

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	CREATE TABLE #tblLogData (
		[RowType] VARCHAR(20)
		,[UserId] INT
		,[FullName] NVARCHAR(100) NULL
		,[Nickname] VARCHAR(30) NULL
		,[EmployeeId] VARCHAR(30) NULL
		,[Skype] VARCHAR(50) NULL
		,[DepartmentId] SMALLINT NULL
		,[SectionId] SMALLINT NULL
		,[Extension] VARCHAR(30) NULL
		,[Phone] VARCHAR(30) NULL
		,[Email] VARCHAR(50) NULL
		,[LocationCode] VARCHAR(10) NULL
		,[CategoryId] SMALLINT NULL
		,[Username] VARCHAR(30) NULL
		,[Pickup] BIT NULL
		,[Address] NVARCHAR(500) NULL
		,[Level] INT NULL
		,[RoleId] SMALLINT NULL
		,[IsSecondAccount] BIT NOT NULL
		,[GroupId] INT NULL
		);

	SET @StartRun = GETDATE()

	--Old Data
	INSERT INTO #tblLogData (
		[RowType]
		,[UserId]
		,[FullName]
		,[Nickname]
		,[EmployeeId]
		,[Skype]
		,[DepartmentId]
		,[SectionId]
		,[Extension]
		,[Phone]
		,[Email]
		,[LocationCode]
		,[CategoryId]
		,[Username]
		,[Pickup]
		,[Address]
		,[Level]
		,[RoleId]
		,[IsSecondAccount]
		,[GroupId]
		)
	SELECT 'OLD'
		,@UserId
		,ou.FullName
		,ou.Nickname
		,ou.EmployeeId
		,ou.Skype
		,ou.DepartmentId
		,ou.SectionId
		,ou.Extension
		,ou.Phone
		,ou.Email
		,ou.LocationCode
		,ou.CategoryId
		,ou.Username
		,ou.Pickup
		,ou.[Address]
		,ou.[LEVEL]
		,ur.RoleId
		,ou.IsSecondAccount
		,ou.GroupId
	FROM [User] ou WITH (NOLOCK)
	LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = ou.UserId
	WHERE ou.UserId = @UserId
	
	UNION
	
	SELECT 'NEW'
		,@UserId
		,ou.FullName
		,ou.Nickname
		,ou.EmployeeId
		,ou.Skype
		,ou.DepartmentId
		,ou.SectionId
		,ou.Extension
		,ou.Phone
		,ou.Email
		,ou.LocationCode
		,ou.CategoryId
		,ou.Username
		,ou.Pickup
		,ou.[Address]
		,ou.[LEVEL]
		,ur.RoleId
		,ou.IsSecondAccount
		,ou.GroupId
	FROM [User] ou WITH (NOLOCK)
	LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = ou.UserId
	WHERE ou.UserId = @UserId

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
				,ISNULL(ou.RoleId, 0) AS '@r'
				,ISNULL(ou.LocationCode, '') AS '@lo'
				,ISNULL(ou.Pickup, '') AS '@pk'
				,ISNULL(ou.[Address], '') AS '@ad'
				,ISNULL(ou.[Level], '') AS '@lv'
				,ISNULL(ou.[IsSecondAccount], '') AS '@sa'
			FROM #tblLogData AS ou
			WHERE ou.RowType = 'OLD'
			FOR XML PATH('z')
				,ROOT('r')
			)
	SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
	SET @Value = NULLIF(@Value, '')
	--Update
	IF @ColumnName = 'EmployeeId'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET EmployeeId = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET EmployeeId = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'FullName'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET FullName = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET FullName = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'NickName'
	BEGIN
		IF EXISTS (
				SELECT TOP 1 u.UserId
				FROM dbo.[User] AS u WITH (NOLOCK)
				WHERE u.UserId <> @UserId
					AND ISNULL(@Value, '') <> ''
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

		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET NickName = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Nickname = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'DepartmentId'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET DepartmentId = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET DepartmentId = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'SectionId'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET SectionId = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET SectionId = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'GroupId'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET GroupId = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET GroupId = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Extension'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Extension = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Extension = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Phone'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Phone = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Phone = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Email'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Email = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Email = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Skype'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Skype = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Skype = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'CategoryId'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET CategoryId = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET CategoryId = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'LocationCode'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET LocationCode = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET LocationCode = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Pickup'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Pickup = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Pickup = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Level'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET [Level] = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET LEVEL = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'Address'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET Address = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET Address = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'IsSecondAccount'
	BEGIN
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET IsSecondAccount = @Value
		WHERE UserId = @UserId

		UPDATE #tblLogData
		SET IsSecondAccount = @Value
		WHERE RowType = 'NEW'
	END

	IF @ColumnName = 'RoleId'
	BEGIN
		DELETE
		FROM dbo.UserRole
		WHERE UserId = @UserId

		IF @Value IS NOT NULL
		BEGIN
			INSERT INTO dbo.UserRole (
				UserId
				,RoleId
				)
			VALUES (
				@UserId
				,@Value
				)
		END

		UPDATE #tblLogData
		SET RoleId = @Value
		WHERE RowType = 'NEW'
	END

	--New data
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
				,ISNULL(ou.RoleId, 0) AS '@r'
				,ISNULL(ou.LocationCode, '') AS '@lo'
				,ISNULL(ou.Pickup, '') AS '@pk'
				,ISNULL(ou.[Address], '') AS '@ad'
				,ISNULL(ou.[Level], '') AS '@lv'
				,ISNULL(ou.[IsSecondAccount], '') AS '@sa'
			FROM #tblLogData AS ou
			WHERE ou.RowType = 'NEW'
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

	DROP TABLE #tblLogData
END