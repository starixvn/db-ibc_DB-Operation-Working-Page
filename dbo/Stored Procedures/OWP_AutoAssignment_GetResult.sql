
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetResult] @RequestId NVARCHAR(MAX)
AS

/*
Created: 20201223@Mira
Task : Other Sport
DB: bodb_OWP

Revisions:
	20201223@Mira: Init SP [Redmine: #146962]
	20210511@Mira: Auto trader assignment - [Redmine: #132710]
	20211228@Tyler: Switch to InfoSiteAutoAssignment - [Redmine: #166161]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT a.Bettype, 
               a.UserId_LA, 
               a.[Group] 'GroupName', 
               a.ExtraTime, 
               o.EventDateTime, 
               u.Username,
               a.IsSaba, 
               a.SabaType
        FROM dbo.InfoSiteAutoAssignmentResult a
             INNER JOIN InfoSiteMatch o ON o.InfoSiteMatchId = a.InfoSiteMatchId
             INNER JOIN dbo.[User] u ON u.UserId = a.UserId_LA
        WHERE a.RequestId = @RequestId;
    END;