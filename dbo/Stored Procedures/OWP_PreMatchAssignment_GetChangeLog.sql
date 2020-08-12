
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetChangeLog] @ObjectId INT
AS

/*      
 Created: 20200811@Mira.Nguyen
 Task : Pre-match Assignment
 DB: bodb_OWP      
 
 Revisions:
    20200811@Mira.Nguyen: Init sp - [Redmine: #138643]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblLogAction TABLE
        (ActionId INT
         PRIMARY KEY
        );

        INSERT INTO @tblLogAction(ActionId)
        VALUES(113), (114), (115);

        SELECT (CASE
                   WHEN lat.ActionTypeId = 2 THEN 'Update Assignment'
                   WHEN lat.ActionTypeId = 3 THEN 'Delete League'
                   WHEN lat.ActionTypeId = 4 THEN 'Recover League'
               END) AS [Action], 
              ul.DataOld AS OldValue, 
              ul.Data AS NewValue, 
              ul.LoggedDate AS LastModified, 
              u.Username AS ModifiedBy
        FROM dbo.UserLog AS ul WITH(NOLOCK)
             INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId
             LEFT JOIN LogAction AS la WITH(NOLOCK) ON la.ActionId = ul.ActionId
             LEFT JOIN LogActionType AS lat WITH(NOLOCK) ON lat.ActionTypeId = la.ActionTypeId
        WHERE ul.ObjectId = @ObjectId
        ORDER BY ul.LoggedDate DESC;
    END;