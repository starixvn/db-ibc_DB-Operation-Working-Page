/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_API_ServiceTimestampUpdate] @ErrCode INT = 0 OUTPUT
	,@ErrMsg NVARCHAR(200) = '' OUTPUT
AS
/*    
 Created: 20161108@Long.Luu
 Task : Update timestamp for Web API call
 DB: bodb_OWP    
    
 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @CurrentDate DATETIME = DATEADD(MI, -1, GETDATE());

		-- UPDATE LAST API CALL INFO
		UPDATE dbo.RefResource WITH (ROWLOCK, UPDLOCK)
		SET [Value] = CONVERT(NVARCHAR(30), @CurrentDate, 9)
		WHERE [RefName] = 'IsSelectedUpdate'
	END TRY

	BEGIN CATCH
		SELECT @ErrMsg = 'Update timestamp failed.'
			,@ErrCode = 2209

		RETURN
	END CATCH
END