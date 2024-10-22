
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignmentRequest_Insert] @RequestId VARCHAR(50)
	,@EventDate DATE
	,@Status INT
	,@CreatorId INT
AS
/*
Created: 20181221@Raymond.Le
Task : Insert auto assignment request
DB: bodb_OWP

Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
*/
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.AutoAssignmentRequest (
		RequestId
		,EventDate
		,[Status]
		,CreatorId
		,RequestDate
		)
	VALUES (
		@RequestId
		,@EventDate
		,@Status
		,@CreatorId
		,GETDATE()
		)
END