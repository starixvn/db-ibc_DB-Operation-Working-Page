
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_RemoveMessageIcon] @MessageId INT, 
                                                            @IconKey   NVARCHAR(200), 
                                                            @CreatorId INT
AS

/*
Created: 20240523@Liam
Task : remove message icon
DB: bodb_OWP

Revisions:

	20240523@Liam: remove message icon  - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        DELETE FROM MessageIcon
        WHERE MessageId = @MessageId
              AND IconKey = @IconKey
              AND CreatorId = @CreatorId;
    END;