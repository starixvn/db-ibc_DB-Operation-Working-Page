CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_GetAllShift] 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT ShiftCode FROM dbo.EmployeeWorkingShift WITH (NOLOCK)
	ORDER BY ShiftCode

END;