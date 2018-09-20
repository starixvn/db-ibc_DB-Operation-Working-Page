CREATE PROCEDURE [dbo].[OWP_UserInsert] @UserId INT
	,@ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*
Created: 20170116@Quinn.Vo
Task: Add user from NAP.
DB: bodb_OWP
Original: 

Revisions:
• 20170301@Tim.Trinh: insert username
Param's Explanation:
• @ErrCode:
	= 0: Transaction recorded successfully.
	> 0: Specific Error.
• @ErrMsg: Error description.

*/
BEGIN
	SET NOCOUNT ON

	DECLARE @username VARCHAR(30)

	IF NOT EXISTS (
			SELECT 1
			FROM dbo.[User] WITH (NOLOCK)
			WHERE UserId = @UserId
			)
	BEGIN
		SELECT @username = username
		FROM bodb02.dbo.Customer WITH (NOLOCK)
		WHERE custid = @UserId

		BEGIN TRY
			INSERT INTO dbo.[User] (
				UserId
				,Username
				)
			VALUES (
				@UserId
				,@username
				)
		END TRY

		BEGIN CATCH
			BEGIN
				SELECT @ErrCode = 1
					,@ErrMsg = 'Insert user failed.'
			END
		END CATCH
	END
END