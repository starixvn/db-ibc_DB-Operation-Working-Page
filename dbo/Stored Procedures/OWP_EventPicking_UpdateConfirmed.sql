
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_UpdateConfirmed] @InfoSiteMatchIds VARCHAR(MAX), 
                                                          @ModifiedBy       VARCHAR(255), 
                                                          @Confirmed        BIT
AS

/*      
 Created: 20230908@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230908@Los: Update confirmed - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @GMT8 DATETIME= DATEADD(hh, 12, GETDATE());
        DECLARE @tempMatch TABLE(InfoSiteMatchId INT);
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@InfoSiteMatchIds, ',') u OPTION(MAXRECURSION 0);
        DELETE c
        FROM EventPickingConfirmed c
             LEFT JOIN @tempMatch m ON c.InfositeId = m.InfoSiteMatchId
        WHERE m.InfoSiteMatchId IS NOT NULL;

        IF @Confirmed = 1
            BEGIN
                INSERT INTO EventPickingConfirmed
                       SELECT m.InfoSiteMatchId
                       FROM @tempMatch m;
        END;
        INSERT INTO EventPickingLog
        ([Date], 
         InfositeId, 
         ModifiedBy, 
         [Action], 
         OldValue, 
         NewValue
        )
               SELECT @GMT8, 
                      t.InfoSiteMatchId, 
                      @ModifiedBy, 
                      'Update the <strong>Checking Status</strong>',
                      CASE @Confirmed
                          WHEN 1
                          THEN 'Unchecked'
                          ELSE 'Checked'
                      END,
                      CASE @Confirmed
                          WHEN 1
                          THEN 'Checked'
                          ELSE 'Unchecked'
                      END
               FROM @tempMatch AS t;
    END;