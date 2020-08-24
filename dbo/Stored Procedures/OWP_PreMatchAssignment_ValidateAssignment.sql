
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchAssignment_ValidateAssignment] @Assignee NVARCHAR(30) = ''
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

        SELECT UserId
        FROM dbo.[User] WITH(NOLOCK)
        WHERE Username = @Assignee;
    END;