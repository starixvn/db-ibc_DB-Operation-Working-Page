CREATE PROCEDURE [dbo].[OWP_MessageTemplateDelete]
	@UserId				INT = 0
	,@MsgTemplateId		INT = 0
	
	,@ErrCode			INT = 0 OUTPUT
	,@ErrMsg			NVARCHAR(200) = '' OUTPUT
/*  
Created: 20161004@Long.Luu
Task : Delete Message Template
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
					,@ErrCode = 2101

				RETURN
			END
		
		DECLARE @MsgTemplateCode NVARCHAR(50)
			, @MsgTemplateDesc NVARCHAR(200)
			, @MsgTemplateContent NVARCHAR(1000)
			, @CreatedBy INT
			, @CreatedDate DATETIME
			, @IsActive BIT
			, @LastModifiedBy INT
			, @LastModifiedDate DATETIME
		
		SELECT @MsgTemplateCode = mt.MsgTemplateCode
			, @MsgTemplateDesc = mt.MsgTemplateDesc
			, @MsgTemplateContent = mt.MsgTemplateContent
			, @CreatedBy = mt.CreatedBy
			, @CreatedDate = mt.CreatedDate
			, @IsActive = mt.IsActive
			, @LastModifiedBy = mt.LastModifiedBy
			, @LastModifiedDate = mt.LastModifiedDate
		FROM dbo.MessageTemplate mt WITH(NOLOCK) 
		WHERE MsgTemplateId = @MsgTemplateId
		
		-- Write Log: Initialize
		DECLARE 
				@StartRun					DATETIME,
				@EndRun						DATETIME,
				@Duration					INT,
				@MessageTemplateData		NVARCHAR(MAX),	
				@Xml						XML 		 
			
		SET @StartRun = GETDATE()
		-- Write Log: End Initialize
		
		DELETE FROM dbo.MessageTemplate
		WHERE MsgTemplateId = @MsgTemplateId
		
		-- Write Log: Continue		
		SET @Xml = (
						SELECT	
							@MsgTemplateCode			AS '@tc',
							@MsgTemplateDesc			AS '@td',
							@MsgTemplateContent			AS '@ct',
							@IsActive					AS '@ia',
							@CreatedBy					AS '@cb',
							@CreatedDate				AS '@cd',
							@LastModifiedBy				AS '@mb',
							@LastModifiedDate			AS '@md'
							FOR XML PATH('z'), ROOT('r')
					)

		SET @MessageTemplateData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

		EXEC	dbo.OWP_WriteLog
				@CreatorId	= @UserId,
				@SPName		= 'OWP_MessageTemplateDelete',
				@LoggedDate	= @StartRun,
				@Duration	= @Duration,
				@ObjectId	= @MsgTemplateId,
				@Data		= NULL,
				@DataOld	= @MessageTemplateData
		-- Write Log: Done
	END TRY
	
	BEGIN CATCH
		ROLLBACK 

		SELECT @ErrMsg = 'Delete message template failed. Please try again.'
			,@ErrCode = 2102

		RETURN
	END CATCH
END