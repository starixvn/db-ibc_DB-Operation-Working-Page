DECLARE @FirstDate DATE, @FromDate DATE
,@ToDate DATE = DATEADD(DAY, -1, GETDATE())
,@MaxDate INT = 0

SET @FirstDate = (SELECT MIN (EventDate) FROM dbo.OWPMatch WITH (NOLOCK))

SET @FromDate = DATEADD(DAY, -1, @FirstDate)
SET @MaxDate = DATEDIFF(DAY,@FromDate,@ToDate)
SELECT @FromDate, @ToDate, @MaxDate, @FirstDate

DELETE FROM
dbo.LSTReport WHERE ReportDate>=@FromDate AND ReportDate <=@ToDate

WHILE (@MaxDate >= 0)
BEGIN
EXEC Task_OWP_LSTReport_CaculateByDate @EventDate = @ToDate
SET @ToDate = DATEADD(DAY, -1, @ToDate)
SET @MaxDate = @MaxDate-1
END