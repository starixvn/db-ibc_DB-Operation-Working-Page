
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_CheckLeagueContainsAnyAssignment] @PreMatchLeagueId INT
AS

/*
Created: 20200821@Tyler
Task : Pre-Match Assignment
DB: bodb_OWP

Revisions:
	20200821@Tyler: Init sync SP - [Redmine: #138643]
	20201003@Tyler: update other assignments  - [Redmine: #142258]  	
*/

     SELECT CASE
                WHEN EXISTS
     (
         SELECT 1
         FROM dbo.[PreMatchAssignment] WITH(NOLOCK)
         WHERE PreMatchLeagueId = @PreMatchLeagueId
     )
                THEN 1
                ELSE 0
            END AS IsContainsAssignment;