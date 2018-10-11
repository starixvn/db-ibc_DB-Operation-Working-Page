/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_GetAllShift]
AS
/*
Created: 20161220@Razor.Nguyen
Task : Get 
DB: bodb_OWP

Revisions:
	20180917@Kane.Le: New structure of event assignment - [Redmine: #92868]
   
*/
BEGIN
	SET NOCOUNT ON;

	SELECT UPPER(NAME) AS ShiftCode
		,CASE 
			WHEN ISNULL(LTRIM(RTRIM(Background)), '') = '' THEN '#ffffff'
			ELSE Background 
			END AS Background
		,CASE 
			WHEN ISNULL(LTRIM(RTRIM(Color)), '') = '' THEN '#000000'
			ELSE Color
			END  AS Color
	FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK)
END;