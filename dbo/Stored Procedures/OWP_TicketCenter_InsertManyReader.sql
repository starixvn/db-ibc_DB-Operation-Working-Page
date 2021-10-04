USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_UpdateIsRead]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketCenter_InsertManyReader] 
	@TicketId INT,
	@RecipientIds VARCHAR(2000),
	@IsRead BIT = NULL
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : Upate is read
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tempRecipientIds TABLE(Id INT);
    
     INSERT INTO @tempRecipientIds(Id)
     SELECT DISTINCT 
                   val
     FROM fnc_SplitStrings(@RecipientIds, ',') u OPTION(MAXRECURSION 0);
     
	INSERT INTO TicketMessageReader( 
		TicketId,
		RecipientId,
		IsRead
	)
	SELECT @TicketId,
		tmp.Id,
		@IsRead
	FROM @tempRecipientIds tmp
END