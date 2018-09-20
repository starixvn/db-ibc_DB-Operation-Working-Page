/* =============================================
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP
-- =============================================*/

CREATE PROCEDURE dbo.OWP_EmployeeWorkingShiftColorSel
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Name], 
           Background, 
           Color
    FROM dbo.EmployeeWorkingShiftColor WITH (NOLOCK);

END;