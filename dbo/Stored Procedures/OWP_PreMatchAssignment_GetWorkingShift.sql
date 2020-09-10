
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.OWP_PreMatchAssignment_GetWorkingShift @EventDate DATE, 
                                                           @UserId    INT
AS

/*  
Created: 20200810@Esther.Nguyen  
Task : Get list working shift 
DB: bodb_OWP  
  
Revisions:  
 20200810@Esther.Nguyen: Get list working shift - [Redmine: #138643]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @sectionId INT;
        SELECT @sectionId = SectionId
        FROM dbo.[User] WITH(NOLOCK)
        WHERE UserId = @UserId;
        SELECT CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END 'NickName', 
               u.UserId, 
               ec.ShiftCode, 
               ec.StartTime, 
               ec.EndTime, 
               ec.Extension, 
               ec.IsTimeShift
        FROM EmployeeWorkingShift AS em WITH(NOLOCK)
             INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON em.EmployeeId = u.UserId
             INNER JOIN EmployeeWorkingShiftColor AS ec WITH(NOLOCK) ON ec.ShiftId = em.ShiftId
        WHERE ShiftDate = @EventDate
              AND u.SectionId = @sectionId
              AND ((ec.IsTimeShift = 1
                    AND ec.StartTime IS NOT NULL
                    AND ec.EndTime IS NOT NULL)
                   OR (ec.IsTimeShift = 0
                       AND ec.ShiftCode IS NOT NULL));
    END;