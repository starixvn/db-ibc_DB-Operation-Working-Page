
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_GetRandDInfo] @Date DATE
AS

/*      
 Created: 20221102@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230907@Liam: Get event picking log - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @Date), '12:00:00');
        DECLARE @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @Date), '11:59:59');
        DECLARE @CheckValue VARCHAR(5000)= 'New';
        DECLARE @InitValue VARCHAR(5000)= 'Initialize';
        DECLARE @TempTime TABLE
        (InfoSiteMatchId INT NOT NULL, 
         ShowDate       DATETIME
        );
        INSERT INTO @TempTime
        (InfoSiteMatchId, 
         ShowDate
        )
               SELECT el.InfositeId, 
                      MAX([date])
               FROM EventPickingLog el WITH(NOLOCK)
                    INNER JOIN InfoSiteMatch im WITH(NOLOCK) ON el.InfositeId = im.InfoSiteMatchId
               WHERE el.OldValue = @InitValue
                     OR el.NewValue = @CheckValue
                     AND im.EventDateTime BETWEEN @FromDateTime AND @ToDateTime
               GROUP BY el.InfositeId;

        SELECT el.InfositeId, 
               ea.UpdateType, 
               ea.RAndDUpdate
        FROM dbo.EventPickingLog AS el WITH(NOLOCK)
             INNER JOIN @TempTime temp ON el.InfositeId = temp.InfoSiteMatchId
             INNER JOIN EventPickingAction ea ON el.UpdateType = ea.UpdateType
        WHERE el.[Date] >= temp.ShowDate;
    END;