USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_UpdateManyRecipientReader]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenter_UpdateManyRecipientReader] 
	@TicketId INT,
	@IsRead BIT = NULL,
	@ActorId int
AS
/*
 Created: 20210917@Carlos.Nguyen
 Task : Upate is read
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
	20211102@Liam.Pham: Ignore ActorId - [Redmine: #162851]
*/
BEGIN
	SET NOCOUNT ON
     
	UPDATE TicketMessageReader
	SET IsRead = @IsRead
	WHERE TicketId=@TicketId and RecipientId <> @ActorId
END