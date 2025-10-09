/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_SaveEditLogs] @XML NVARCHAR(MAX)
AS

/*
Created: 20251006@Hank
Task: save MB logs
DB: bodb_OWP

Revisions:
    20251006@Hank: Init - [Redmine: #239417]
*/

BEGIN
    SET NOCOUNT ON;
    
    DECLARE @idoc INT;
    DECLARE @tblLog TABLE
    (InfositeId   INT, 
     [Date]       DATETIME NOT NULL, 
     [UpdateTypeId] INT, 
     [ModifiedBy] VARCHAR(5000),
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
     [ModifiedBy],
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
           [ModifiedBy],
           [Action], 
           [OldValue], 
           [NewValue],
           [HomeUpdated],
           [AwayUpdated],
           [FromService]
    FROM OPENXML(@idoc, '/Root/LoggedChangeModel', 1) 
    WITH([InfoSiteMatchId] INT, 
         [UpDateTime] DATETIME, 
         [UpdateTypeId] INT,
         [ModifiedBy] VARCHAR(5000),
         [Action] VARCHAR(5000), 
         [OldValue] VARCHAR(5000), 
         [NewValue] VARCHAR(5000), 
         [HomeUpdated] BIT, 
         [AwayUpdated] BIT, 
         [FromService] NVARCHAR(50));
    
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
           [ModifiedBy], 
           [Action], 
           [OldValue], 
           [NewValue],
           [HomeUpdated],
           [AwayUpdated],
           [FromService]
    FROM @tblLog;
END;