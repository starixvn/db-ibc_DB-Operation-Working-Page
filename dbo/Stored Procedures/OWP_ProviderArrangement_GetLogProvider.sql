
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProviderArrangement_GetLogProvider]
AS

/*      
 Created: 20230110@Johnny.Thai
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230110@Johnny.Thai: Init sp - [Redmine: #181896]
*/

    BEGIN
        SET NOCOUNT ON;

        -- log info -- 
        SELECT ul.LoggedDate AS ModifiedDate, 
               u.Username AS ModifiedBy, 
               ul.DataOld, 
               ul.Data
        FROM dbo.UserLog AS ul WITH(NOLOCK)
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId
        WHERE ul.ActionId = 130
        ORDER BY ul.LoggedDate ASC;
    END;