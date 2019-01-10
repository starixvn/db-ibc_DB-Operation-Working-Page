
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RefResource_Insert] @RefName VARCHAR(30)
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

	INSERT INTO dbo.RefResource (		
		RefName
		,ResourceId
		,Value
		)
	VALUES (
		@RefName
		,1
		,@Value
		)
END