
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE OWP_PreMatchAssignment_GetStartTimeForNightShift @EventDate DATE
AS

/*  
Created: 20200817@Esther.Nguyen  
Task : Pre-Match Assignment
DB: bodb_OWP  
  
Revisions:  
	20200817@Esther.Nguyen: Get start time for night shift  - [Redmine: #138643] 
 	20201003@Tyler: update other assignments  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     SELECT [StartTime]
     FROM PreMatchNightShiftStartTime WITH(NOLOCK)
     WHERE EventDate = @EventDate;