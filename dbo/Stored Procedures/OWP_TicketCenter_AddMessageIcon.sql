
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_AddMessageIcon] @MessageId INT, 
                                                         @IconKey   NVARCHAR(200), 
                                                         @CreatorId INT
AS

/*
Created: 20240523@Liam
Task : add message icon
DB: bodb_OWP

Revisions:

	20240523@Liam: add message icon  - [Redmine: #201603]
*/

    BEGIN
        SET NOCOUNT ON;
        INSERT INTO MessageIcon
        (MessageId, 
         IconKey, 
         CreatorId
        )
        VALUES
        (@MessageId, 
         @IconKey, 
         @CreatorId
        );
    END;