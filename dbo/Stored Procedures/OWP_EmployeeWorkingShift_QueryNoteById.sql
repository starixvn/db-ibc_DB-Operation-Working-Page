/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_QueryNoteById] @EmployeeWorkingShiftNoteId INT
AS
/*
Created: 20191015@Tyler.Dang
Task : Insert new EmployeeWorkingShift Note
DB: bodb_OWP

Revisions:
	20191015@Tyler.Dang: Init SP - [Redmine: #121901]
*/
BEGIN
	SET NOCOUNT ON;

    DECLARE @TimeZoneGMT8 INT = 8;
	SELECT ewn.UserId
		,ewn.EmployeeWorkingShiftNoteId
		,ewn.Note
		,u.Username AS UserName
		,DATEADD(HH, @TimeZoneGMT8, (DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), ewn.CreatedDate))) AS LastUpdated
	FROM dbo.[EmployeeWorkingShiftNote] AS ewn WITH (NOLOCK)
	INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON ewn.CreatedBy = u.UserId
	WHERE ewn.EmployeeWorkingShiftNoteId = @EmployeeWorkingShiftNoteId

END