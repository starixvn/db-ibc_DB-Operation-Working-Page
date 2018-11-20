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
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @StartRun DATETIME
		,@EndRun DATETIME
		,@Duration INT
		,@LogDataOld NVARCHAR(MAX)
		,@LogData NVARCHAR(MAX)
		,@Xml XML

	CREATE TABLE #OldUser (
		UserId INT
		,FullName NVARCHAR(200)
		,NickName VARCHAR(30)
		,EmployeeId VARCHAR(30)
		,CategoryId SMALLINT
		,Extension VARCHAR(30)
		,Phone VARCHAR(30)
		,Email VARCHAR(50)
		,Skype VARCHAR(50)
		,DepartmentId SMALLINT
		,SectionId SMALLINT
		,RoleId SMALLINT
		,Pickup BIT
		,LocationCode VARCHAR(10)
		,Address NVARCHAR(500)
		,Level NVARCHAR(10)
		)

	IF @UserId IS NOT NULL
	BEGIN TRY
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

		SET @StartRun = GETDATE()

		--Get Old data
		INSERT INTO #OldUser (
			UserId
			,FullName
			,NickName
			,EmployeeId
			,CategoryId
			,Extension
			,Phone
			,Email
			,Skype
			,DepartmentId
			,SectionId
			,RoleId
			,LocationCode
			,Pickup
			,Address
			,Level
			)
		SELECT u.UserId
			,u.FullName
			,u.Nickname
			,u.EmployeeId
			,u.CategoryId
			,u.Extension
			,u.Phone
			,u.Email
			,u.Skype
			,u.DepartmentId
			,u.SectionId
			,ur.RoleId
			,u.LocationCode
			,u.Pickup
			,u.Address
			,u.Level
		FROM [User] u WITH (NOLOCK)
			LEFT JOIN dbo.UserRole AS ur WITH (NOLOCK) ON ur.UserId = u.UserId
		WHERE u.UserId = @UserId

		IF @Nickname IS NOT NULL
			AND EXISTS (
				SELECT u.UserId
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

			PRINT '5802'

			RETURN
		END

		--Update
		UPDATE dbo.[User] WITH (UPDLOCK, ROWLOCK)
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
			,Level = @Level
		WHERE UserId = @UserId

		DELETE
		FROM dbo.UserRole
		WHERE UserId = @UserId

		IF(@RoleId IS NOT NULL)
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

		--Old Data
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(ou.FullName, '') <> ISNULL(@FullName, '') THEN ou.FullName
						ELSE NULL
						END AS '@fn'
					,CASE 
						WHEN ISNULL(ou.NickName, '') <> ISNULL(@NickName, '') THEN ou.NickName
						ELSE NULL
						END AS '@nn'
					,CASE 
						WHEN ISNULL(ou.EmployeeId, '') <> ISNULL(@EmployeeId, '') THEN ou.EmployeeId
						ELSE NULL
						END AS '@eid'
					,CASE 
						WHEN ISNULL(ou.CategoryId, 0) <> ISNULL(@CategoryId, 0) THEN ou.CategoryId
						ELSE NULL
						END AS '@ca'
					,CASE 
						WHEN ISNULL(ou.Extension, '') <> ISNULL(@Extension, '') THEN ou.Extension
						ELSE NULL
						END AS '@ex'
					,CASE 
						WHEN ISNULL(ou.Phone, '') <> ISNULL(@Phone, '') THEN ou.Phone
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(ou.Email, '') <> ISNULL(@Email, '') THEN ou.Email
						ELSE NULL
						END AS '@e'
					,CASE 
						WHEN ISNULL(ou.Skype, '') <> ISNULL(@Skype, '') THEN ou.Skype
						ELSE NULL
						END AS '@s'
					,CASE 
						WHEN ISNULL(ou.DepartmentId, 0) <> ISNULL(@DepartmentId, 0) THEN ou.DepartmentId
						ELSE NULL
						END AS '@d'
					,CASE 
						WHEN ISNULL(ou.SectionId, 0) <> ISNULL(@SectionId, 0) THEN ou.SectionId
						ELSE NULL
						END AS '@sec'
					,CASE 
						WHEN ISNULL(ou.RoleId, 0) <> ISNULL(@RoleId, 0) THEN ou.RoleId
						ELSE NULL
						END AS '@r'
					,CASE 
						WHEN ISNULL(ou.LocationCode, '') <> ISNULL(@LocationCode, '') THEN ou.LocationCode
						ELSE NULL
						END AS '@lo'
					,CASE 
						WHEN ISNULL(ou.Pickup, '') <> ISNULL(@Pickup, '') THEN ou.Pickup
						ELSE NULL
						END AS '@pk'
					,CASE 
						WHEN ISNULL(ou.Address, '') <> ISNULL(@Address, '') THEN ou.Address
						ELSE NULL
						END AS '@ad'
					,CASE 
						WHEN ISNULL(ou.Level, '') <> ISNULL(@Level, '') THEN ou.Level
						ELSE NULL
						END AS '@lv'
				FROM #OldUser AS ou
				FOR XML PATH('z')
					,ROOT('r')
				)
		SET @LogDataOld = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')

		--New data
		SET @Xml = (
				SELECT CASE 
						WHEN ISNULL(ou.FullName, '') <> ISNULL(@FullName, '') THEN ISNULL(@FullName, '')
						ELSE NULL
						END AS '@fn'
					,CASE 
						WHEN ISNULL(ou.NickName, '') <> ISNULL(@NickName, '') THEN ISNULL(@NickName, '')
						ELSE NULL
						END AS '@nn'
					,CASE 
						WHEN ISNULL(ou.EmployeeId, '') <> ISNULL(@EmployeeId, '') THEN ISNULL(@EmployeeId, '')
						ELSE NULL
						END AS '@eid'
					,CASE 
						WHEN ISNULL(ou.CategoryId, 0) <> ISNULL(@CategoryId, 0) THEN ISNULL(@CategoryId, '')
						ELSE NULL
						END AS '@ca'
					,CASE 
						WHEN ISNULL(ou.Extension, '') <> ISNULL(@Extension, '') THEN ISNULL(@Extension, '')
						ELSE NULL
						END AS '@ex'
					,CASE 
						WHEN ISNULL(ou.Phone, '') <> ISNULL(@Phone, '') THEN ISNULL(@Phone, '')
						ELSE NULL
						END AS '@p'
					,CASE 
						WHEN ISNULL(ou.Email, '') <> ISNULL(@Email, '') THEN ISNULL(@Email, '')
						ELSE NULL
						END AS '@e'
					,CASE 
						WHEN ISNULL(ou.Skype, '') <> ISNULL(@Skype, '') THEN ISNULL(@Skype, '')
						ELSE NULL
						END AS '@s'
					,CASE 
						WHEN ISNULL(ou.DepartmentId, 0) <> ISNULL(@DepartmentId, 0) THEN ISNULL(@DepartmentId, '')
						ELSE NULL
						END AS '@d'
					,CASE 
						WHEN ISNULL(ou.SectionId, 0) <> ISNULL(@SectionId, 0) THEN ISNULL(@SectionId, '')
						ELSE NULL
						END AS '@sec'
					,CASE 
						WHEN ISNULL(ou.RoleId, 0) <> ISNULL(@RoleId, 0) THEN ISNULL(@RoleId, '')
						ELSE NULL
						END AS '@r'
					,CASE 
						WHEN ISNULL(ou.LocationCode, '') <> ISNULL(@LocationCode, '') THEN ISNULL(@LocationCode, '')
						ELSE NULL
						END AS '@lo'
					,CASE 
						WHEN ISNULL(ou.Pickup, '') <> ISNULL(@Pickup, '') THEN ou.Pickup
						ELSE NULL
						END AS '@pk'
					,CASE 
						WHEN ISNULL(ou.Address, '') <> ISNULL(@Address, '') THEN ou.Address
						ELSE NULL
						END AS '@ad'
					,CASE 
						WHEN ISNULL(ou.Level, '') <> ISNULL(@Level, '') THEN ou.Level
						ELSE NULL
						END AS '@lv'
				FROM #OldUser AS ou
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