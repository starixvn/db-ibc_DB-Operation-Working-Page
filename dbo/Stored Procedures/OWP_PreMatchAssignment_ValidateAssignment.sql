USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_PreMatchAssignment_ValidateAssignment]    Script Date: 8/28/2020 2:40:28 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_ValidateAssignment] @Assignee NVARCHAR(30) = ''
AS

/*
Created: 20200817@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200817@Tyler: Init sync SP - [Redmine: #138643]
	
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT UserId, 
               Username
        FROM dbo.[User] WITH(NOLOCK)
        WHERE Username = @Assignee
              OR Nickname = @Assignee;
    END;