
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_EventPicking_SaveLogs] @XML NVARCHAR(MAX)
AS

/*      
 Created: 20221102@Liam 
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230907@Liam: save event picking log - [Redmine: #190039]
	20231016@los: Export event picking [Redmine: #194448]
	20240708@Johnny: refactor - [Redmine: #201604]  
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        DECLARE @tblLog TABLE
        (InfositeId   INT, 
         [Date]       DATETIME NOT NULL, 
         UpdateTypeId INT, 
         [Action]     VARCHAR(5000), 
         [NewValue]   VARCHAR(5000), 
         [OldValue]   VARCHAR(5000),
		 [HomeUpdated] BIT,
		 [AwayUpdated] BIT,
		 [FromService] NVARCHAR(50)
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        INSERT INTO @tblLog
        (InfositeId, 
         [Date], 
         UpdateTypeId, 
         [Action], 
         [OldValue], 
         [NewValue],
		 [HomeUpdated],
		 [AwayUpdated],
		 [FromService]
        )
               SELECT [InfoSiteMatchId], 
                      [UpDateTime], 
                      NULLIF([UpdateTypeId], ''), 
                      [Action], 
                      [OldValue], 
                      [NewValue],
					  [HomeUpdated],
					  [AwayUpdated],
					  [FromService]
               FROM OPENXML(@idoc, '/Root/LoggedChangeModel', 1) WITH([InfoSiteMatchId] INT, [UpDateTime] DATETIME, [UpdateTypeId] INT, [Action] VARCHAR(5000), [OldValue] VARCHAR(5000), [NewValue] VARCHAR(5000), [HomeUpdated] BIT, [AwayUpdated] BIT, [FromService] NVARCHAR(50));
        EXEC sp_xml_removedocument 
             @idoc;
        INSERT INTO EventPickingLog
        (InfositeId, 
         [Date], 
         UpdateTypeId, 
         ModifiedBy, 
         [Action], 
         [OldValue], 
         [NewValue],
		 [HomeUpdated],
		 [AwayUpdated],
		 [FromService]
        )
               SELECT InfositeId, 
                      [Date], 
                      UpdateTypeId, 
                      'System', 
                      [Action], 
                      [OldValue], 
                      [NewValue],
					  [HomeUpdated],
					  [AwayUpdated],
					  [FromService]
               FROM @tblLog;

        -- delete match checked 
        DELETE e
        FROM EventPickingConfirmed e
             INNER JOIN @tblLog tl ON e.InfositeId = tl.InfositeId;
    END;