
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
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
*/
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.RefResource
	WITH (ROWLOCK)

	SET [Value] = @Value
	WHERE RefName = @RefName
		AND ResourceId = @ResourceId
END