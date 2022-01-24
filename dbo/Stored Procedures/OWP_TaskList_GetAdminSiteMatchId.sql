
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TaskList_GetAdminSiteMatchId] @OWPMatchId INT
AS

/*    
 Created: 20220120@Tyler
 Task : get AdminSiteMatchId for OWP task list
 DB: bodb_OWP    
    
 Revisions:
	20220120@Tyler: Initial SP - [Redmine: #167774]
	
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT im.AdminSiteMatchId
        FROM InfoSiteMatch im
             INNER JOIN OWPMatch m ON m.InfoSiteMatchId = im.InfoSiteMatchId
        WHERE m.OWPMatchId = @OWPMatchId;
    END;