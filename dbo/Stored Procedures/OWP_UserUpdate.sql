
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_UserUpdate] @Editor INT
	,@UserId INT
	,@FullName NVARCHAR(200) = NULL
	,@NickName VARCHAR(30) = NULL
	,@EmployeeId VARCHAR(30) = NULL
	,@CategoryId SMALLINT = NULL
	,@Extension VARCHAR(30) = NULL
	,@Phone VARCHAR(30) = NULL
	,@Email VARCHAR(50) = NULL
	,@Skype VARCHAR(50) = NULL
	,@DepartmentId SMALLINT = NULL
	,@SectionId SMALLINT = NULL
	,@RoleId SMALLINT = NULL
	,@LocationCode VARCHAR(10) = NULL
	,@Pickup BIT = NULL
	,@Address NVARCHAR(500) = NULL
	,@LEVEL NVARCHAR(10) = NULL
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
*/
BEGIN
	SET NOCOUNT ON

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

	IF EXISTS (
			SELECT TOP 1 u.UserId
			FROM dbo.[User] AS u WITH (NOLOCK)
			WHERE u.UserId <> @UserId
				AND (
					u.Nickname = @NickName
					OR u.Username = @NickName
					)
			)
	BEGIN
		SELECT @ErrMsg = 'Nickname already exists!'
			,@ErrCode = 5802

		RETURN
	END

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	 
	BEGIN TRY
		SET @StartRun = GETDATE()		 
		--Old Data
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
					,ISNULL(ur.RoleId, 0) AS '@r'
					,ISNULL(ou.LocationCode, '') AS '@lo'
					,ISNULL(ou.Pickup, '') AS '@pk'
					,ISNULL(ou.Address, '') AS '@ad'
					,ISNULL(ou.LEVEL, '') AS '@lv'
				FROM [User] ou WITH (NOLOCK)
				LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = ou.UserId
				WHERE ou.UserId = @UserId
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		--Update
		UPDATE dbo.[User]
		WITH (
				UPDLOCK
				,ROWLOCK
				)

		SET FullName = @FullName
			,Nickname = @NickName
			,EmployeeId = @EmployeeId
			,CategoryId = @CategoryId
			,Extension = @Extension
			,Phone = @Phone
			,Email = @Email
			,Skype = @Skype
			,DepartmentId = @DepartmentId
			,SectionId = @SectionId
			,LocationCode = @LocationCode
			,Pickup = @Pickup
			,Address = @Address
			,LEVEL = @Level
		WHERE UserId = @UserId

		DELETE
		FROM dbo.UserRole
		WHERE UserId = @UserId

		IF (@RoleId IS NOT NULL)
		BEGIN
			INSERT INTO dbo.UserRole (
				UserId
				,RoleId
				)
			VALUES (
				@UserId
				,@RoleId
				)
		END

		--New data
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
					,ISNULL(@RoleId, 0) AS '@r'
					,ISNULL(@LocationCode, '') AS '@lo'
					,ISNULL(@Pickup, '') AS '@pk'
					,ISNULL(@Address, '') AS '@ad'
					,ISNULL(@Level, '') AS '@lv'
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun)

		EXEC dbo.OWP_WriteLog @CreatorId = @Editor
			,@SPName = 'OWP_UserUpdate'
			,@LoggedDate = @StartRun
			,@Duration = @Duration
			,@ObjectId = @UserId
			,@Data = @LogData
			,@DataOld = @LogDataOld
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update User failed. Please try again!'
			,@ErrCode = 5803

		RETURN
	END CATCH
END