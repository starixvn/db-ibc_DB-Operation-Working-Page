CREATE PROCEDURE [dbo].[OWP_MessageStatusUpdate]
	@UserId			INT = 0
	,@MessageId		INT = 0
	,@IsViewed		BIT = 1
	
	,@ErrCode		INT = 0 OUTPUT
	,@ErrMsg		NVARCHAR(200) = '' OUTPUT
/*  
Created: 20161004@Long.Luu
Task : Get all messages by User ID 
DB: bodb_OWP  
  
Revisions:  
     
*/
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS(SELECT COUNT(1) FROM dbo.MessageUser mu WITH(NOLOCK) WHERE UserId = @UserId AND MessageId = @MessageId)
			BEGIN
				SELECT @ErrMsg = 'This message does not exist. Please try again.'
					,@ErrCode = 2201

				RETURN
			END
			
		-- Write Log: Initialize
		DECLARE 
				@StartRun					DATETIME,
				@EndRun						DATETIME,
				@Duration					INT,
				@MessageUserData			NVARCHAR(MAX),	
				@Xml						XML 		 
			
		SET @StartRun = GETDATE()
		-- Write Log: End Initialize
		
		UPDATE dbo.MessageUser  WITH(UPDLOCK, ROWLOCK)
		SET IsViewed = @IsViewed
		WHERE UserId = @UserId AND MessageId = @MessageId
		
		DECLARE @MessageUserId INT = 0
		SELECT @MessageUserId = mu.MessageUserId
		FROM dbo.MessageUser mu WITH(NOLOCK)
		WHERE MessageId = @MessageId AND UserId = @UserId
		
		-- Write Log: Continue		
		SET @Xml = (
						SELECT	
							@MessageId			AS '@ms',
							@UserId				AS '@us',
							@IsViewed			AS '@iv'
							FOR XML PATH('z'), ROOT('r')
					)

		SET @MessageUserData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

		EXEC	dbo.OWP_WriteLog
				@CreatorId	= @UserId,
				@SPName		= 'OWP_MessageStatusUpdate',
				@LoggedDate	= @StartRun,
				@Duration	= @Duration,
				@ObjectId	= @MessageUserId,
				@Data		= @MessageUserData,
				@DataOld	= NULL
		-- Write Log: Done
	END TRY
	
	BEGIN CATCH
		ROLLBACK 

		SELECT @ErrMsg = 'Update message status failed. Please try again.'
			,@ErrCode = 2202

		RETURN
	END CATCH
END