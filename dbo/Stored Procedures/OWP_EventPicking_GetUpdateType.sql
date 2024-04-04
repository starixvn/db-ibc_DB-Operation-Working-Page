
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetUpdateType]
AS

/*      
 Created: 20230908@Mira
 Task : Get update type
 DB: bodb_OWP      
 
 Revisions:
    20230908@Mira: Get update type - [Redmine: #190039]
	20240404@Liam: ignore round H-A/T - [Redmine: #202638]
*/

    BEGIN
        SET NOCOUNT ON;

        -- select league
        SELECT Id 'Value', 
               UpdateType 'Label'
        FROM dbo.EventPickingUpDateType AS im WITH(NOLOCK)
        WHERE im.Id NOT IN(14, 15);
    END;