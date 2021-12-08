USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId]    Script Date: 09/23/2021 11:18:03 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] @ActorId INT
AS

/*      
 Created: 20210917@Carlos.Nguyen
 Task : Get event ticket
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211130@Tyler: Get pinned prop - [Redmine: #165017]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT tr.TicketId, 
               tr.IsPinned
        FROM TicketRecipient AS tr
        WHERE tr.RecipientType = 1
              AND tr.RecipientId = @ActorId
        UNION
        SELECT tr.TicketId, 
               tr.IsPinned
        FROM TicketRecipient AS tr
             INNER JOIN RecipientGroup AS rg ON tr.RecipientId = rg.GroupId
        WHERE tr.RecipientType = 2
              AND rg.RecipientId = @ActorId;
    END;