/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250313@Frankie
Task : missing log eventpicking
DB: bodb_OWP

Revisions:
	20250313@Frankie: log wrong and miss log event picking  - [Redmine: #219935]
*/

SELECT
    Subquery.*
INTO #temp
FROM (
    SELECT
        log.*,
        CASE
            WHEN DATEPART(HOUR, oldvalue) < 12 THEN CAST(DATEADD(DAY, -1, oldvalue) AS DATE)
            ELSE CAST(oldvalue AS DATE)
        END AS OldDate_System,
        CASE
            WHEN DATEPART(HOUR, newvalue) < 12 THEN CAST(DATEADD(DAY, -1, newvalue) AS DATE)
            ELSE CAST(newvalue AS DATE)
        END AS NewDate_System
    FROM dbo.EventPickingLog as log WITH(NOLOCK)
    WHERE
        Date >= '2025-1-1' AND UpdateTypeId = 2
) AS Subquery
WHERE
    OldDate_System <> NewDate_System;

INSERT INTO [dbo].[EventPickingLog] (
    [Date],
    [InfositeId],
    [UpdateTypeId],
    [ModifiedBy],
    [Action],
    [OldValue],
    [NewValue],
    [HomeUpdated],
    [AwayUpdated],
    [FromService]
)
SELECT
    [Date],
    [InfositeId],
    24,
    [ModifiedBy],
    'Move <b>KO Date</b>',
    [OldValue],
    [NewValue],
    [HomeUpdated],
    [AwayUpdated],
    [FromService]
FROM #temp;

INSERT INTO [dbo].[EventPickingLog] (
    [Date],
    [InfositeId],
    [UpdateTypeId],
    [ModifiedBy],
    [Action],
    [OldValue],
    [NewValue],
    [HomeUpdated],
    [AwayUpdated],
    [FromService]
)
SELECT
    [Date],
    [InfositeId],
    25,
    [ModifiedBy],
    'Renew Match',
    [OldValue],
    [NewValue],
    [HomeUpdated],
    [AwayUpdated],
    [FromService]
FROM #temp;

DELETE FROM [dbo].[EventPickingLog]
WHERE Id IN (SELECT Id FROM #temp);

drop table #temp

