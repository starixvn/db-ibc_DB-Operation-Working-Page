/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShiftColorUpd] 
    @Name       nvarchar(50), 
    @Background varchar(50), 
    @Color      varchar(50)
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

    UPDATE dbo.EmployeeWorkingShiftColor WITH(ROWLOCK)
    SET Background = @Background, 
        Color = @Color
    WHERE Name = @Name;

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.EmployeeWorkingShiftColor( [Name], 
                                           Background, 
                                           Color
               )
        VALUES(@Name, @Background, @Color)
    END;
END;