
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RefResource_Insert] @RefName VARCHAR(30)
	,@Value NVARCHAR(50)
	,@ResourceId INT = NULL OUTPUT
AS
/*
Created: 20190110@Kane.Le
Task : RefResourceManagement
DB: bodb_OWP

Revisions:	 
	20190110@Kane.Le: Init SP  [Redmine: #107257]
	20190122@Kane.Le: Check duplicate value  [Redmine: #108206]
*/
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS (
			SELECT TOP 1 ref.ResourceId
			FROM dbo.RefResource ref WITH (NOLOCK)
			WHERE LOWER(LTRIM(RTRIM(ref.[Value]))) = LOWER(LTRIM(RTRIM(@Value)))
			)
	BEGIN
		DECLARE @MaxResourceId INT

		SELECT @MaxResourceId = MAX(ResourceId)
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = @RefName

		SELECT @MaxResourceId = ISNULL((@MaxResourceId + 1), 1)

		INSERT INTO dbo.RefResource (
			RefName
			,ResourceId
			,Value
			)
		VALUES (
			@RefName
			,@MaxResourceId
			,@Value
			)

		SET @ResourceId = @MaxResourceId
	END
END