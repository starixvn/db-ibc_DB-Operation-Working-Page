
/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/

ALTER FUNCTION [dbo].[fnc_GetDateTimeForTraderViewTime]()
RETURNS @TraderViewTime TABLE
(FromTime DATETIME, 
 ToTime   DATETIME
)
AS

/*
Created: Quinn.Vo@20170421
Task: Get date time for trader view time.
DB: bodb_OWP

Param's Explanation:
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
	20200713@Mira: NewTimeRange - [Redmine: #137410]
*/

     BEGIN
         DECLARE @FakeDate DATETIME = GETDATE()
		 DECLARE @GMT8 DATETIME = DATEADD(hh, 12, @FakeDate)
		 DECLARE @Today DATETIME= DATEADD(dd, 0, DATEDIFF(dd, 0, @GMT8));
         DECLARE @FromTime DATETIME= @Today;
         DECLARE @NextDays DATETIME= DATEADD(hh, 36, @Today);
         DECLARE @ToTime DATETIME= DATEADD(ss, -1, @NextDays); 
		 
         INSERT INTO @TraderViewTime
         (FromTime, 
          ToTime
         )
         VALUES
         (@FromTime, 
          @ToTime
         );
         RETURN;
     END;
