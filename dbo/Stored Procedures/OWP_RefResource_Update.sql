
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RefResource_Update] @RefName VARCHAR(30)
	,@ResourceId INT
	,@Value NVARCHAR(50)
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
			WHERE RefName = @RefName
				AND LOWER(LTRIM(RTRIM(ref.[Value]))) = LOWER(LTRIM(RTRIM(@Value)))
			)
	BEGIN
		UPDATE dbo.RefResource
		WITH (ROWLOCK)

		SET [Value] = @Value
		WHERE RefName = @RefName
			AND ResourceId = @ResourceId
	END
END