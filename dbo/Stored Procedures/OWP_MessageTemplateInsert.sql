CREATE PROCEDURE [dbo].[OWP_MessageTemplateInsert]
	@UserId					INT = 0
	,@MsgTemplateCode		INT = 0
	,@MsgTemplateDesc		NVARCHAR(200) = ''
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
		IF EXISTS(SELECT COUNT(1) FROM dbo.MessageTemplate mt WITH(NOLOCK) WHERE MsgTemplateCode = @MsgTemplateCode)
			BEGIN
				SELECT @ErrMsg = 'This message template code existed. Please pick another one.'
					,@ErrCode = 1901

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
		
		DECLARE @MessageTemplateId INT = 0
		
		INSERT INTO dbo.MessageTemplate(
			MsgTemplateCode
			, MsgTemplateDesc
			, MsgTemplateContent
			, CreatedBy
			, CreatedDate
			, IsActive)
		VALUES(
			@MsgTemplateCode
			, @MsgTemplateDesc
			, @MsgTemplateContent
			, @UserId
			, GETDATE()
			, @IsActive)
		
		SELECT @MessageTemplateId = SCOPE_IDENTITY()
		
		-- Write Log: Continue		
		SET @Xml = (
						SELECT	
							@MsgTemplateCode			AS '@tc',
							@MsgTemplateDesc			AS '@td',
							@MsgTemplateContent			AS '@ct',
							@UserId						AS '@cb',
							GETDATE()					AS '@cd',
							@IsActive					AS '@ia'
							FOR XML PATH('z'), ROOT('r')
					)

		SET @MessageTemplateData = REPLACE(CONVERT(NVARCHAR(MAX), @Xml), '" />', '"/"')
		
		SET @EndRun = GETDATE()
		SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun) 

		EXEC	dbo.OWP_WriteLog
				@CreatorId	= @UserId,
				@SPName		= 'OWP_MessageTemplateInsert',
				@LoggedDate	= @StartRun,
				@Duration	= @Duration,
				@ObjectId	= @MessageTemplateId,
				@Data		= @MessageTemplateData,
				@DataOld	= NULL
		-- Write Log: Done
	END TRY
	
	BEGIN CATCH
		ROLLBACK 

		SELECT @ErrMsg = 'Insert new message template failed. Please try again.'
			,@ErrCode = 1902

		RETURN
	END CATCH
END