
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
         DECLARE @Today DATETIME= DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()));
         DECLARE @OWPToday DATETIME= DATEADD(hh, 12, GETDATE());
         DECLARE @FromTime DATETIME= DATEADD(hh, 12, @Today);
         DECLARE @NextDays DATETIME= DATEADD(hh, 24, @FromTime);
         DECLARE @ToTime DATETIME= DATEADD(ss, -1, @NextDays);

         IF(DATEDIFF(SECOND, DATEADD(DAY, DATEDIFF(DAY, 0, @OWPToday), '11:59:59'), @OWPToday) < 0)
             BEGIN
                 SELECT @FromTime = @FromTime, 
                        @ToTime = DATEADD(dd, 1, @ToTime);
         END;

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