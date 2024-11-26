
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_SaveMatchDeleteLogs] @Xml NVARCHAR(MAX)
AS
 
/*       
 Created: 20221102@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230907@Liam: save delete event picking log - [Redmine: #190039]
	20241126@Frankie: adjust the auto uncheck - [Redmine: #214103]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Xml;
        DECLARE @DeleteMatchTemp TABLE
        (InfositeId   INT, 
         [Date]       DATETIME NOT NULL, 
         UpdateTypeId INT, 
         ModifiedBy   VARCHAR(5000), 
         [Action]     VARCHAR(5000), 
         [OldValue]   VARCHAR(5000), 
         [NewValue]   VARCHAR(5000)
        );

        INSERT INTO @DeleteMatchTemp
        (InfositeId, 
         [Date], 
         UpdateTypeId, 
         ModifiedBy, 
         [Action], 
         [OldValue], 
         [NewValue]
        )
               SELECT [InfoSiteMatchId], 
                      [UpDateTime], 
                      [UpdateTypeId], 
                      'System', 
                      [Action], 
					  [OldValue],
                      [NewValue]
               FROM OPENXML(@idoc, '/Root/LoggedChangeModel', 1) WITH([InfoSiteMatchId] INT, [UpDateTime] DATETIME, [UpdateTypeId] INT, [Action] VARCHAR(5000), [NewValue] VARCHAR(5000), [OldValue] VARCHAR(5000));
        EXEC sp_xml_removedocument 
             @idoc;

        -- Log the matches that will be deleted.
        INSERT INTO EventPickingLog
        (InfositeId, 
         [Date], 
         UpdateTypeId, 
         ModifiedBy, 
         [Action], 
         [OldValue], 
         [NewValue]
        )
               SELECT InfositeId, 
                      [Date], 
                      [UpdateTypeId], 
                      ModifiedBy, 
                      [Action], 
                      [OldValue], 
					  [NewValue]
               FROM @DeleteMatchTemp t
                    INNER JOIN InfoSiteMatch im ON t.InfositeId = im.InfoSiteMatchId
               WHERE im.IsDeleted = 0;

		-- Log the matches that will be unchecked
		INSERT INTO EventPickingLog
        (InfositeId, 
         [Date], 
         ModifiedBy, 
         [Action], 
         [OldValue], 
         [NewValue]
        )
               SELECT ec.InfositeId, 
                      [Date], 
					  ModifiedBy,
                      'Update the <b>checking status</b>', 
                      'Checked', 
                      'Unchecked'
               FROM @DeleteMatchTemp t
                    INNER JOIN EventPickingConfirmed ec ON t.InfositeId = ec.InfositeId
					INNER JOIN InfoSiteMatch im ON t.InfositeId = im.InfoSiteMatchId
			   WHERE im.IsDeleted = 0
       
	   -- delete match checked 
        DELETE e
        FROM EventPickingConfirmed e
             INNER JOIN @DeleteMatchTemp t ON e.InfositeId = t.InfositeId
			 INNER JOIN InfoSiteMatch im ON t.InfositeId = im.InfoSiteMatchId
		WHERE im.IsDeleted = 0
    END;