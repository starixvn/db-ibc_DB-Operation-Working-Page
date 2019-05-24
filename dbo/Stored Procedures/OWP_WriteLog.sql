
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_WriteLog] @CreatorId INT
	,@SPName NVARCHAR(128) = NULL
	,@LoggedDate DATETIME = NULL
	,@Duration INT = NULL
	,@ObjectId INT = NULL
	,@Data NVARCHAR(MAX) = NULL
	,@DataOld NVARCHAR(MAX) = NULL
AS
/*
Created: 20160930@Long.Luu
Task : Write log user runs store procedure
DB:  DBOWP.bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20190520@Leo.Vo: Write log - [Redmine: #113763]
*/
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.UserLog (
		CreatorId
		,LoggedDate
		,ObjectId
		,ActionId
		,Duration
		,Data
		,DataOld
		)
	SELECT @CreatorId
		,@LoggedDate
		,@ObjectID
		,ActionID
		,@Duration
		,@Data
		,@DataOld
	FROM dbo.LogAction WITH (NOLOCK)
	WHERE SPName = @SPName
END