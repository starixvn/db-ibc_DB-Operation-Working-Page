
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_ViewLog] @ObjectId INT,
	@PageSize INT
AS
/*      
 Created: 20191025@leo.vo  
 Task : Working Shift Management
 DB: bodb_OWP      
 
 Revisions:
     20191025@leo.vo: initial SP [#233604]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblWorkingShiftLogAction TABLE (
		ActionId INT PRIMARY KEY
	)
	
	INSERT INTO @tblWorkingShiftLogAction (ActionId)
	VALUES (74), (75), (76), (77), (78), (79), (84), (85), (87), (89)

	SELECT TOP (@PageSize) ul.LoggedDate AS ModifiedDate
		,ISNULL(u.Username, 'System') AS ModifiedBy
		,ul.ActionId
		,ul.DataOld
		,ul.Data
	FROM dbo.UserLog AS ul WITH (NOLOCK)
	INNER JOIN @tblWorkingShiftLogAction AS la ON ul.ActionId = la.ActionId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ul.CreatorId = u.UserId
	WHERE ul.ObjectId = @ObjectId
	ORDER BY ul.LoggedDate DESC
END;