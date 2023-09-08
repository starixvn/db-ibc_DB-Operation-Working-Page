
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_EventPicking_SaveLogs] @Xml NVARCHAR(MAX)
AS

/*      
 Created: 20221102@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20230907@Liam: save event picking log - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Xml;
        INSERT INTO EventPickingLog
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
                      [NewValue], 
                      [OldValue]
               FROM OPENXML(@idoc, '/Root/LoggedChangeModel', 1) WITH([InfoSiteMatchId] INT, [UpDateTime] DATETIME, [UpdateTypeId] INT, [Action] VARCHAR(5000), [NewValue] VARCHAR(5000), [OldValue] VARCHAR(5000));
        EXEC sp_xml_removedocument 
             @idoc;
    END;