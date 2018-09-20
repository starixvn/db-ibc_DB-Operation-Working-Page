CREATE PROCEDURE [dbo].[OWP_WriteLog]
	@CreatorId	INT,
	@SPName		VARCHAR(50) = NULL,
	@LoggedDate	DATETIME = NULL,
	@Duration	INT = NULL,
	@ObjectId	INT = NULL,
	@Data		NVARCHAR(MAX) = NULL,
	@DataOld	NVARCHAR(MAX) = NULL

/*
Created: 20160930@Long.Luu
Task : Write log user runs store procedure
DB:  DBOWP.bodb_OWP

Revisions:
   
*/ 

AS
BEGIN 
SET NOCOUNT ON 

INSERT INTO dbo.UserLog(
			 CreatorId
			,LoggedDate
			,ObjectId
			,ActionId
			,Duration
			,Data
			,DataOld)
	SELECT	 @CreatorId
			,@LoggedDate
			,@ObjectID
			,ActionID
			,@Duration
			,@Data
			,@DataOld			
	FROM	dbo.LogAction WITH (NOLOCK)
	WHERE	SPName = @SPName

END