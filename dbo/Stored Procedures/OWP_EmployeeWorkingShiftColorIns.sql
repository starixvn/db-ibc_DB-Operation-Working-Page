/* =============================================
Created: 20180213@Jacob
Task: Employee Working Shift Management
DB: bodb_OWP
-- =============================================*/

CREATE PROCEDURE dbo.OWP_EmployeeWorkingShiftColorIns 
    @WorkingShift xml = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TempTable TABLE
    ( 
        Name       nvarchar(50), 
        Background varchar(50), 
        Color      varchar(50)
    );
    INSERT INTO @TempTable( Name, 
                            Background, 
                            Color
           )
           SELECT t.c.value('@Name', 'NVARCHAR(50)') AS Name, 
                  t.c.value('@Background', 'VARCHAR(20)') AS Background, 
                  t.c.value('@Color', 'VARCHAR(20)') AS Color
           FROM @WorkingShift.nodes('Data/Row') AS t(c);


    INSERT INTO dbo.EmployeeWorkingShiftColor( Name, 
                                       Background, 
                                       Color
           )
           SELECT t.Name, 
                  t.Background, 
                  t.Color
           FROM @TempTable AS t
           WHERE NOT EXISTS(
                               SELECT 1
                               FROM dbo.EmployeeWorkingShiftColor AS w WITH(NOLOCK)
                               WHERE w.Name = t.Name
                           );


END;