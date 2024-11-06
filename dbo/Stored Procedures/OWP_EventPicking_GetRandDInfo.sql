
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_GetRandDInfo] @Date DATE
AS

/*      
 Created: 20221102@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230907@Liam: Get event picking log - [Redmine: #190039]
	20231016@los: Export event picking [Redmine: #194448]
	20240404@Liam: ignore round H-A/T - [Redmine: #202638]
	20241106@Frankie: sort R&D column - [Redmine: #212795]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');
        DECLARE @CheckValue VARCHAR(5000)= 'Checked';
        DECLARE @InitValue VARCHAR(5000)= 'Initialize';
        DECLARE @TempTime TABLE
        (InfoSiteMatchId INT NOT NULL, 
         ShowDate        DATETIME
        );
        INSERT INTO @TempTime
        (InfoSiteMatchId, 
         ShowDate
        )
               SELECT el.InfositeId, 
                      MAX([date])
               FROM EventPickingLog el WITH(NOLOCK)
                    INNER JOIN InfoSiteMatch im WITH(NOLOCK) ON el.InfositeId = im.InfoSiteMatchId
               WHERE(el.NewValue = @CheckValue
                     OR el.OldValue = @InitValue)
                    AND im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime
               GROUP BY el.InfositeId;
        SELECT DISTINCT 
               el.InfositeId, 
               eu.Id AS UpdateTypeId, 
               eu.RAndDUpdate, 
               el.AwayUpdated, 
               el.HomeUpdated,
			   el.[Date]
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
             INNER JOIN @TempTime temp ON el.InfositeId = temp.InfoSiteMatchId
             INNER JOIN EventPickingUpDateType eu WITH(NOLOCK) ON el.UpdateTypeId = eu.Id
        WHERE el.[Date] >= temp.ShowDate
              AND eu.Id NOT IN(14, 15)
		ORDER BY el.[Date];
    END;