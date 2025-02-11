
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LogMonitoring_Insert] @CreatedDate DATE,
@Action VARCHAR(255),
@Payload NVARCHAR(MAX)
AS

/*
 Created: 20250210@Los
 Task : write log
 DB: bodb_OWP

 Revisions:
	20250210@Los: Write log - [Feature: #213719]
*/

     SET NOCOUNT ON;
     INSERT INTO LogMonitoring(CreatedDate,[Action],
[Payload])
VALUES(@CreatedDate,@Action,@Payload)
