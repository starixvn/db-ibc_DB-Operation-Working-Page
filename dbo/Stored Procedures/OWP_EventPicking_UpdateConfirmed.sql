
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_UpdateConfirmed] @InfoSiteMatchIds VARCHAR(MAX), 
                                                          @ModifiedBy       VARCHAR(255), 
                                                          @Confirmed        BIT,
														  @ConfirmedAt		DATETIME
AS

/*      
 Created: 20230908@Los
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230908@Los: Update confirmed - [Redmine: #190039]
    20250530@Frankie: handle check time - [Redmine: #227875]
*/

    BEGIN
        SET NOCOUNT ON;
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
                       FROM @tempMatch m
					   WHERE NOT EXISTS (
							SELECT 1
							FROM EventPickingLog
							WHERE [InfositeId] = m.InfoSiteMatchId
								AND [UpdateTypeId] IS NOT NULL
								AND [Date] > @ConfirmedAt
					);
        END;
        INSERT INTO EventPickingLog
        ([Date], 
         InfositeId, 
         ModifiedBy, 
         [Action], 
         OldValue, 
         NewValue
        )
			SELECT @ConfirmedAt, 
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
			FROM @tempMatch AS t	
    END;