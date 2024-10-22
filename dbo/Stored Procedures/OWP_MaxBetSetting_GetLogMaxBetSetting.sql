
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MaxBetSetting_GetLogMaxBetSetting] @FT_HDP INT
AS

/*      
 Created: 20220831@Johnny.Thai
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20220831@Johnny.Thai: Init sp - [Redmine: #176781]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblMaxbetSettingLogAction TABLE(ActionId INT);
        INSERT INTO @tblMaxbetSettingLogAction(ActionId)
        VALUES(128);
        SELECT ul.LoggedDate AS ModifiedDate, 
               u.Username AS ModifiedBy, 
               ul.ActionId AS [Action], 
               ul.DataOld, 
               ul.Data
        FROM dbo.UserLog AS ul WITH(NOLOCK)
             INNER JOIN @tblMaxbetSettingLogAction AS sp ON ul.ActionId = sp.ActionId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId
        WHERE ul.ObjectId = @FT_HDP;
    END;