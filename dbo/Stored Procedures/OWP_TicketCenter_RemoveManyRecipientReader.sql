USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_RemoveManyRecipientReader]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketCenter_RemoveManyRecipientReader] 
	@TicketId INT,
	@RecipientIds VARCHAR(MAX)
AS
/*
 ALTERd: 20210917@Carlos.Nguyen
 Task : Remove many recipient reader
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
     
	DELETE FROM TicketMessageReader
	FROM TicketMessageReader AS tm
	INNER JOIN @tempRecipientIds AS tmp ON tm.RecipientId=tmp.id
	WHERE tm.TicketId=@TicketId
END