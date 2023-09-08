
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetUpdateType]
AS

/*      
 Created: 20230908@Mira
 Task : Get update type
 DB: bodb_OWP      
 
 Revisions:
    20230908@Mira: Get update type - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;

        -- select league
        SELECT Id 'Value', 
               UpdateType 'Label'
        FROM dbo.EventPickingUpDateType AS im WITH(NOLOCK);
    END;