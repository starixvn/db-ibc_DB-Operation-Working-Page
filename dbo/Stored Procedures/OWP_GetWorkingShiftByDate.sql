/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/ 
ALTER  PROCEDURE dbo.OWP_GetWorkingShiftByDate 
	@EventDate Date
AS
/*  
Created: 20200810@Esther.Nguyen  
Task : Get list working shift 
DB: bodb_OWP  
  
Revisions:  
 20200810@Esther.Nguyen: Get list working shift - [Redmine: #139219]  
*/  

BEGIN  
 SET NOCOUNT ON;  
 DECLARE  @tblShift TABLE (ShiftId INT)
 DECLARE  @ShiftIds  varchar(500)
     	 
	 SELECT  @ShiftIds = coalesce(@ShiftIds + ',', '') +  convert(varchar(12),ShiftId)
						FROM EmployeeWorkingShift
						WHERE ShiftDate = @EventDate				
	
	INSERT INTO @tblShift (ShiftId)
	SELECT DISTINCT t.val
	FROM dbo.fnc_SplitStrings(@ShiftIds, ',') AS t
	OPTION (MAXRECURSION 0)
	
	SELECT CASE WHEN u.Nickname IS NULL THEN u.Username ELSE  u.Nickname END 'NickName',
		   u.UserId,
		   ec.ShiftCode,
		   ec.StartTime,
		   ec.EndTime,
		   ec.Extension,
		   ec.IsTimeShift
	FROM EmployeeWorkingShift as em WITH (NOLOCK)
	INNER JOIN dbo.[User] as u WITH (NOLOCK) ON em.EmployeeId = u.UserId
	INNER JOIN @tblShift AS ts ON ts.ShiftId = em.ShiftId
	LEFT JOIN EmployeeWorkingShiftColor AS ec  WITH (NOLOCK) ON  ec.ShiftId = ts.ShiftId
    WHERE ShiftDate = @EventDate AND
	 ((
		ec.IsTimeShift = 1
		AND ec.StartTime IS NOT NULL
		AND ec.EndTime IS NOT NULL
		)
	OR (
		ec.IsTimeShift = 0
		AND ec.ShiftCode IS NOT NULL
		))
END;    		 

      
	