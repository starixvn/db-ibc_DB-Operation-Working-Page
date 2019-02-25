/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_EmployeeWorkingShift_Upload] 
    @Data xml
AS
/*      
 Created: 20180312@Leo.Vo     
 Task : Working Shift Management
 DB: bodb_OWP      
      
 Revisions:      
     20180925@Raymond: calculate shift time
	 20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
     
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
BEGIN
    SET NOCOUNT ON;
    DECLARE @tempTable TABLE
    ( 
        EmployeeId int, 
        ShiftId  int, 
        ShiftDate  date,
		ShiftStartTime datetime,
		ShiftEndTime datetime
    );

    INSERT INTO @tempTable
           SELECT M.C.value('@EmployeeId', 'INT'), 
                  M.C.value('@ShiftId', 'INT'), 
                  M.C.value('@ShiftDate', 'DATE'),
				  M.C.value('@ShiftStartTime', 'DATETIME'),
				  M.C.value('@ShiftEndTime', 'DATETIME')
           FROM @Data.nodes('Data/Row') AS M(C);

    MERGE dbo.EmployeeWorkingShift AS t1
    USING(
             SELECT EmployeeId, 
                    ShiftId, 
                    ShiftDate,
					ShiftStartTime,
					ShiftEndTime
             FROM @tempTable
         ) AS t2
    ON t1.EmployeeId = t2.EmployeeId AND 
       t1.ShiftDate = t2.ShiftDate
    WHEN MATCHED
          THEN UPDATE SET t1.ShiftId = t2.ShiftId
						,t1.ShiftStartTime = t2.ShiftStartTime
						,t1.ShiftEndTime = t2.ShiftEndTime
    WHEN NOT MATCHED
          THEN
          INSERT(EmployeeId, 
                 ShiftId, 
                 ShiftDate,
				 ShiftStartTime,
				 ShiftEndTime)
          VALUES(t2.EmployeeId, t2.ShiftId, t2.ShiftDate, t2.ShiftStartTime, t2.ShiftEndTime);
END;