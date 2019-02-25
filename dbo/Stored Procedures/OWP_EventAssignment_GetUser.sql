
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EventAssignment_GetUser] @EventDate DATE
AS
/*  
 Created: Leo.Vo@20181205
 Task : Get all user for event assignment
 DB: bodb_OWP

 Revisions:
	20181205@Leo.Vo: Initial SP - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	SELECT u.UserId
		,u.Username
		,u.Nickname
		,u.Extension
		,u.Phone
		,u.Skype
		,r.Value AS [Level]
		,wsc.ShiftCode
		,wsc.Background AS ShiftBackground
		,wsc.Color AS ShiftColor
	FROM dbo.[User] AS u WITH (NOLOCK)
		LEFT JOIN dbo.RefResource AS r WITH (NOLOCK) ON u.[Level] = r.ResourceId
		AND r.RefName = 'UserLevel'
		LEFT JOIN dbo.EmployeeWorkingShift AS ws WITH (NOLOCK) ON u.UserId = ws.EmployeeId
		AND ShiftDate = @EventDate
		LEFT JOIN dbo.EmployeeWorkingShiftColor AS wsc WITH (NOLOCK) ON ws.ShiftId = wsc.ShiftId
END