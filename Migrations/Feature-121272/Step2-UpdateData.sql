 /*
	Created: Kane.Le
	Date: 20191002
	Task: Update LogItems [Redmine: #121272]
	DB: bodb_OWP
*/

UPDATE dbo.LogAction
SET LogItems='<root><xml path="r/z" /><row item="ShiftId" alias="sid" /><row item="ShiftCode" alias="sc" /><row item="Background" alias="bg" /><row item="Color" alias="c" /><row item="StartTime" alias="st" /><row item="EndTime" alias="et" /><row item="IsTimeShift" alias="its" /><row item="Extension" alias="ext" /></root>'
WHERE SPName='OWP_EmployeeWorkingShift_QuickInsert_WorkingShiftColor'