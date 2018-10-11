/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_NotificationSetting_Update] @NotificationSettingId INT
	,@UserId INT
	,@Value NVARCHAR(250)	 
AS
/*          
 Created: 20180925@Kane.Le
 Task : Get All NotificationSetting By UserId
 DB: bodb_OWP_Test          
          
 Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868] 
         
*/
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
			SELECT 1
			FROM dbo.NotificationSettingMapping WITH (NOLOCK)
			WHERE NotificationSettingId = @NotificationSettingId
				AND UserId = @UserId
			)
	BEGIN
		UPDATE dbo.NotificationSettingMapping WITH (ROWLOCK, UPDLOCK)
		SET Value = @Value
		WHERE NotificationSettingId = @NotificationSettingId
			AND UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO dbo.NotificationSettingMapping (
			NotificationSettingId
			,UserId
			,Value
			)
		VALUES (
			@NotificationSettingId
			,@UserId
			,@Value
			);
	END	
	RETURN
END