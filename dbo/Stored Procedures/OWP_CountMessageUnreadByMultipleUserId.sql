USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_CountMessageUnreadByMultipleUserId]    Script Date: 01/06/2021 10:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_CountMessageUnreadByMultipleUserId] @UserIds VARCHAR(MAX)
AS
/*    
 Created: 20220217@Carlos.nguyen
 Task : CountUnreadMessage
 DB: bodb_OWP    
    
 Revisions:
	20220217@Carlos.nguyen: Initial SP - [Redmine: #168468]
	
*/
BEGIN
	SET NOCOUNT ON

     DECLARE @allUserIds TABLE(UserId INT);
     INSERT INTO @allUserIds
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@UserIds, ',') u OPTION(MAXRECURSION 0);
    
	SELECT COUNT(reader.RecipientId) AS Total,
		reader.RecipientId AS UserId
	FROM TicketMessageReader AS reader
		INNER JOIN @allUserIds AS u ON reader.RecipientId=u.UserId
	WHERE GroupId IS NULL
		AND IsRead=0
	GROUP BY reader.RecipientId
END