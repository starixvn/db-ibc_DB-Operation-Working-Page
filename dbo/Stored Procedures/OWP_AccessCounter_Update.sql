
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AccessCounter_Update]
	@ActorId INT,
	@FunctionName VARCHAR(500)
AS

/*
Created: 20230717@Los
Task : Create table AccessCounter
DB: bodb_OWP

Revisions:
	20230717@Los: Create table AccessCounter [Redmine: #189526]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @currentDate DATETIME=CAST( GETDATE() AS Date )

		IF EXISTS (SELECT 1 FROM AccessCounter WHERE [Date] = @currentDate AND [UserId]=@ActorId AND [Function]=@FunctionName)  
		BEGIN  
			UPDATE a  
			SET a.[Count]=a.[Count]+1
			FROM AccessCounter AS a WITH (NOLOCK) 
			WHERE [Date] = @currentDate AND [UserId]=@ActorId AND [Function]=@FunctionName
		END  
		ELSE  
		BEGIN  
			INSERT INTO AccessCounter(
				[Date],
				[UserId],
				[Function],
				[Count]
			)
			VALUES(
				@currentDate,
				@ActorId,
				@FunctionName,
				1
			)
		END
    END;