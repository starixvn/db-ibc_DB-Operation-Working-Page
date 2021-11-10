USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_RecipientGroup_RemoveMessageReader]    Script Date: 11/4/2021 1:39:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_RecipientGroup_RemoveMessageReader]
	@GroupId INT,
	@UserIds VARCHAR(MAX)
AS
/*      
 Created: 20211104@Johnny.Thai
 Task : Remove recipientIndividual reader when remove user to group
 DB: bodb_OWP      
      
 Revisions:          
	20211104@Johnny.Thai:Notification for Ticket Center - [Redmine: #162851]
*/
BEGIN

	SET NOCOUNT ON
	
	DECLARE @tempMessageReader TABLE(Id INT, UserId VARCHAR(2000));
	DECLARE @tempUser TABLE(Id INT);
	DECLARE @recipientGroup INT =2;
	DECLARE @tempMessageReaderDeleted TABLE(Id INT);
	
	INSERT INTO @tempUser
    SELECT DISTINCT 
    val
    FROM fnc_SplitStrings(@UserIds, ',') u OPTION(MAXRECURSION 0);
    
    INSERT INTO @tempMessageReader(Id, UserId)
    SELECT tr.Id,
		tr.RecipientId
    FROM TicketMessageReader AS tr
    WHERE tr.RecipientType=@recipientGroup AND tr.GroupId=@GroupId
    
    INSERT INTO @tempMessageReaderDeleted
    SELECT tm.Id
    FROM @tempMessageReader AS tm LEFT JOIN @tempUser AS tu
		ON tm.UserId=tu.Id
	WHERE tu.Id IS NULL
    
	DELETE FROM TicketMessageReader
	FROM TicketMessageReader AS tm
	INNER JOIN @tempMessageReaderDeleted AS tmp ON tm.Id=tmp.id

END