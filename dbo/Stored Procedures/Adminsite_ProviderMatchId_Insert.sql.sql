
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[Adminsite_ProviderMatchId_Insert] @ProviderMatchIdJson VARCHAR(MAX)
AS

/*
 Created: 20250210@Los
 Task : insert provider match id
 DB: bodb_OWP

 Revisions:
	20250210@Los: insert provider match id - [Feature: #213719]
*/

     SET NOCOUNT ON;
     INSERT INTO LogMonitoring(CreatedDate,[Action],
[Payload])
VALUES(@CreatedDate,@Action,@Payload)
