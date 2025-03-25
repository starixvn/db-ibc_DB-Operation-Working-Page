
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_InternalSystem_WriteLog] @CreatedDate DATETIME,
@Action VARCHAR(255),
@Payload NVARCHAR(MAX)
AS

/*
 Created: 20250210@Los
 Task : write log
 DB: bodb_OWP

 Revisions:
	20250210@Los: Write log - [Feature: #217894]
*/

     SET NOCOUNT ON;
     INSERT INTO OWPLogs(CreatedDate,[Action],
[Payload])
VALUES(@CreatedDate,@Action,@Payload)
