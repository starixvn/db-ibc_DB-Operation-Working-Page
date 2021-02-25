
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_AutoAssignment_GetResult] @RequestId NVARCHAR(MAX)
AS

/*
Created: 20201223@Mira
Task : Other Sport
DB: bodb_OWP

Revisions:
	20201223@Mira: Init SP [Redmine: #146962]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT a.OWPMatchId, 
               a.Bettype, 
               a.UserId, 
               a.GroupName, 
               a.ExtraTime, 
               o.KickOffTime,
			   u.Username
        FROM dbo.AutoAssignmentResult a
             INNER JOIN dbo.OWPMatch o ON o.OWPMatchId = a.OWPMatchId
             INNER JOIN dbo.[User] u ON u.UserId = a.UserId
        WHERE a.RequestId = @RequestId;
    END;