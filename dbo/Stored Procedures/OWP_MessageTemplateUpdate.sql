CREATE PROCEDURE [dbo].[OWP_MessageTemplateUpdate]
	@UserId				INT = 0
	,@MsgTemplateId		INT = 0
	,@MsgTemplateDesc	NVARCHAR(200) = ''
	,@MsgTemplateContent	NVARCHAR(1000) = ''
	,@IsActive				BIT = 0
	
	,@ErrCode				INT = 0 OUTPUT
	,@ErrMsg				NVARCHAR(200) = '' OUTPUT
/*  
Created: 20161004@Long.Luu
Task : Update Message Template's info
DB: bodb_OWP  
  
Revisions:  
     
*/
AS
BEGIN
	SET NOCOUNT ON
		
	BEGIN TRY
		IF EXISTS(SELECT COUNT(1) FROM dbo.MessageTemplate mt WITH(NOLOCK) WHERE MsgTemplateId = @MsgTemplateId)
			BEGIN
				SELECT @ErrMsg = 'This message template does not exist. Please try again.'
					,@ErrCode = 2001

				RETURN
			END
			
		-- Write Log: Initialize
		DECLARE 
				@StartRun					DATETIME,
				@EndRun						DATETIME,
				@Duration					INT,
				@MessageTemplateData		NVARCHAR(MAX),	
				@Xml						XML 		 
			
		SET @StartRun = GETDATE()
		-- Write Log: End Initialize
		
		UPDATE dbo.MessageTemplate WITH(UPDLOCK, ROWLOCK)
		SET MsgTemplateDesc = @MsgTemplateDesc
			, MsgTemplateContent = @MsgTemplateContent
			, IsActive = @IsActive
			, LastModifiedBy = @UserId
			, LastModifiedDate = GETDATE()
		WHERE MsgTemplateId = @MsgTemplateId
		
		-- Write Log: Continue		
		SET @Xml = (
						SELECT	
							@MsgTemplateDesc			AS '@td',
							@MsgTemplateContent			AS '@ct',
							@IsActive					AS '@ia',
							@UserId						AS '@mb',
							GETDATE()					AS '@md'
							FOR XML PATH('z'), ROOT('r')
					)

		SET @MessageTemplateData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

		EXEC	dbo.OWP_WriteLog
				@CreatorId	= @UserId,
				@SPName		= 'OWP_MessageTemplateUpdate',
				@LoggedDate	= @StartRun,
				@Duration	= @Duration,
				@ObjectId	= @MsgTemplateId,
				@Data		= @MessageTemplateData,
				@DataOld	= NULL
		-- Write Log: Done
	END TRY
	
	BEGIN CATCH
		ROLLBACK 

		SELECT @ErrMsg = 'Update message template failed. Please try again.'
			,@ErrCode = 2002

		RETURN
	END CATCH
END