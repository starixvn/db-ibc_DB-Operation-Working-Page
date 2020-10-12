-- Indexing on column ShiftCode on table EmployeeWorkingShift
CREATE NONCLUSTERED INDEX IX_EmployeeWorkingShift_ShiftCode 
	ON dbo.EmployeeWorkingShift (ShiftCode ASC)
	ON OWP_Index;