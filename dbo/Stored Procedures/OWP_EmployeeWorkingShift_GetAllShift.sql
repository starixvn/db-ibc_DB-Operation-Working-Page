/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_GetAllShift]
AS
/*
Created: 20161220@Razor.Nguyen
Task : Get 
DB: bodb_OWP

Revisions:
	20180917@Kane.Le: Get Color of Shift
   
*/
BEGIN
	SET NOCOUNT ON;

	SELECT Name AS ShiftCode
		,Background
		,Color
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
END;