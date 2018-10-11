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
*/
BEGIN
    SET NOCOUNT ON;
    SELECT [Name], 
           Background, 
           Color
    FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK);

END;