USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenter_GetRecipientIndividualInManyGroup]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetRecipientIdInManyGroup] 
	@GroupIds VARCHAR(MAX)
AS
/*
 Created: 20210917@Carlos.Nguyen
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
     FROM fnc_SplitStrings(@GroupIds, ',') u OPTION(MAXRECURSION 0);
     
	SELECT DISTINCT rg.RecipientId
	FROM RecipientGroup AS rg
	INNER JOIN @tempRecipientIds as tmp ON tmp.Id=rg.RecipientGroupId 
END