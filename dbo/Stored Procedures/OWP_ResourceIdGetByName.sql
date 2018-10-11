/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_ResourceIdGetByName]    
   @ResourceType  VARCHAR(30)    
  ,@ResourceValues NVARCHAR(MAX)         
  ,@ResourceIds  NVARCHAR(200) = '' OUTPUT    
/*    
Created: 20161027@Long.Luu    
Task : Get ResourceId by Name    
DB: bodb_OWP    
    
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]   
*/    
    
AS    
BEGIN    
	SET NOCOUNT ON    

	IF (@ResourceValues = '' OR @ResourceValues IS NULL)
	BEGIN
		SET @ResourceIds = ''
		RETURN
	END

	DECLARE @Resources TABLE(      
		RowIndex INT IDENTITY(1,1)    
		,ResourceValue NVARCHAR(20)    
	)    
	 
	INSERT INTO @Resources(ResourceValue)    
	SELECT CAST(VAL as NVARCHAR(20))  AS ResourceValue    
	FROM dbo.strSplit(@ResourceValues,',')    

	DECLARE @TotalRow INT    
		,@rowIndex INT    

	SELECT @TotalRow = COUNT(1)    
	FROM @Resources    

	SET @rowIndex = 1    
	WHILE @rowIndex <= @TotalRow    
		BEGIN    
			DECLARE @Value NVARCHAR(200)    
			DECLARE @Id  INT = -1    
			SELECT @Value = LTRIM(RTRIM(r.ResourceValue))    
			FROM @Resources r    
			WHERE r.RowIndex = @rowIndex    
			
			IF (@Value IS NOT NULL AND @Value <> '')
				BEGIN
					SELECT TOP 1 @Id = rr.ResourceId    
					FROM dbo.RefResource rr WITH(NOLOCK)    
					WHERE rr.RefName = @ResourceType AND rr.Value = @Value    
					 
					IF @Id <> -1    
						BEGIN    
							SET @ResourceIds = @ResourceIds + CAST(@Id AS VARCHAR(5)) + ','    
						END    
					ELSE    
						BEGIN    
							DECLARE @MaxResourceId INT    
							DECLARE @NewResourceId INT    
							SELECT @MaxResourceId = MAX(rr.ResourceId)    
							FROM dbo.RefResource rr WITH(NOLOCK)    
							WHERE rr.RefName = @ResourceType    
							--------------------------------
							-- Insert new RefName
							IF @MaxResourceId IS NULL
								BEGIN
									SET @MaxResourceId = 0
								END
							--------------------------------
							INSERT INTO dbo.RefResource(RefName, ResourceId, Value)    
							VALUES(@ResourceType, @MaxResourceId + 1, @Value)    
							    
							SET @ResourceIds = @ResourceIds + CAST((@MaxResourceId + 1) AS VARCHAR(5)) + ','    
						END    
				END
			SET @rowIndex = @rowIndex + 1
		END     
	 
	SET @ResourceIds = SUBSTRING(@ResourceIds, 0, LEN(@ResourceIds))  
    
END