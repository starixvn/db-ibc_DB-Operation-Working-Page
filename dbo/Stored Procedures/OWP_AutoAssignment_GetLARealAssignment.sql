CREATE PROCEDURE OWP_AutoAssignment_GetLARealAssignment @UserIds NVARCHAR(MAX),
															@EventDate DATE
AS

/*
Created: 20201223@Tyler
Task : Auto LA - Results verification
DB: bodb_OWP

Revisions:
	20201223@Tyler: Initial - [Redmine: #150268]
	
*/

    BEGIN
        SET NOCOUNT ON;
        -- temp User
        DECLARE @tblUserId TABLE(UserId INT);
        INSERT INTO @tblUserId
               SELECT DISTINCT 
                      [Value]
               FROM fnc_SplitString(@UserIds, ',') u OPTION(MAXRECURSION 0);      

        -- Result
        SELECT u.Username,
		rg.[Value] 'Group',
		rl.[Value] 'Level'
		FROM dbo.[User] u
		inner join @tblUserId ud on ud.UserId = u.UserId
		left join dbo.[RefResource] rg on rg.ResourceId = u.GroupId AND rg.RefName = 'UserGroup'
		left join dbo.[RefResource] rl on rl.ResourceId = u.[Level] AND rl.RefName = 'UserLevel'
		left join dbo.[EmployeeWorkingShift] ws on ws.EmployeeId = u.UserId AND ws.ShiftDate = @EventDate;

		DELETE @tblUserId;
    END;
