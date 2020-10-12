/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_GetAllSessionLST]
AS

/*
Created: 20200727@Esther.Nguyen
Task : Ready to Trade Status  
DB: bodb_OWP

Revisions:
	20200723@Esther.Nguyen: Staff's readiness notification - [Redmine: #137751]
*/

    BEGIN
        SELECT u.UserId 'AssigneeId', 
               u.Username 'AssigneeName'
        FROM dbo.[User] AS u WITH(NOLOCK)
             INNER JOIN dbo.RefResource AS sec WITH(NOLOCK) ON u.SectionId = sec.ResourceId                                                           
                                                               AND Value = 'LST';
    END;