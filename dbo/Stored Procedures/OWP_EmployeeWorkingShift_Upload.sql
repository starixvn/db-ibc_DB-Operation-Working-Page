/*      
 Created: 20180312@Leo.Vo     
 Task : Working Shift Management
 DB: bodb_OWP      
      
 Revisions:      
     
 -- @Note:    
 EXEC OWP_EmployeeWorkingShift_Upload @Data=N'
<Data>
 <Row EmployeeId="8" ShiftCode="AL" Date="2018/03/12" />
 <Row EmployeeId="8" ShiftCode="OFF" Date="2018/03/13" />
 <Row EmployeeId="2339" ShiftCode="AL" Date="2018/03/12" />
 <Row EmployeeId="2339" ShiftCode="OFF" Date="2018/03/13" />
</Data>
'
*/

CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Upload] 
    @Data xml
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tempTable TABLE
    ( 
        EmployeeId int, 
        ShiftCode  varchar(50), 
        ShiftDate  date
    );

    INSERT INTO @tempTable
           SELECT M.C.value('@EmployeeId', 'INT'), 
                  UPPER(M.C.value('@ShiftCode', 'varchar(50)')), 
                  M.C.value('@ShiftDate', 'DATE')
           FROM @Data.nodes('Data/Row') AS M(C);

    MERGE dbo.EmployeeWorkingShift AS t1
    USING(
             SELECT EmployeeId, 
                    ShiftCode, 
                    ShiftDate
             FROM @tempTable
         ) AS t2
    ON t1.EmployeeId = t2.EmployeeId AND 
       t1.ShiftDate = t2.ShiftDate
    WHEN MATCHED
          THEN UPDATE SET t1.ShiftCode = t2.ShiftCode
    WHEN NOT MATCHED
          THEN
          INSERT(EmployeeId, 
                 ShiftCode, 
                 ShiftDate)
          VALUES(t2.EmployeeId, t2.ShiftCode, t2.ShiftDate);
END;