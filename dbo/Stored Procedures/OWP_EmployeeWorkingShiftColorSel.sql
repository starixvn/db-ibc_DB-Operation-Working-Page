/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftColorSel]
AS
/*
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP

Param's Explanation:

Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20190125@Kane.Le: Change Name to ShiftCode - [Redmine: #108206]
*/
BEGIN
    SET NOCOUNT ON;
    SELECT [ShiftCode], 
           Background, 
           Color
    FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK);

END;