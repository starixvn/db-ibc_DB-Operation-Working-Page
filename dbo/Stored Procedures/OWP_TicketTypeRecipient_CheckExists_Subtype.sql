
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketTypeRecipient_CheckExists_Subtype] @Xml NVARCHAR(MAX)
AS

/*    
Created: 20220225@carlos.Nguyen  
Task : Get lít subtype exists
DB: bodb_OWP  
    
Revisions:    
  20220225@carlos.Nguyen  : Initial SP - [Redmine: #168624] 
*/

    BEGIN
        SET NOCOUNT ON;
        
        DECLARE @idoc INT
        
        EXEC sp_xml_preparedocument @idoc OUTPUT
		,@XML
		
        DECLARE @tblSubtypeName TABLE( Name NVARCHAR(100))
        
        INSERT INTO @tblSubtypeName (Name)
        SELECT [SubtypeName] FROM OPENXML(@idoc, '/Root/SubtypeChecker', 1) WITH (
			[SubtypeName] [NVARCHAR](100)
        )
        EXEC sp_xml_removedocument @idoc
        
        SELECT ts.SubtypeName
        FROM @tblSubtypeName AS tblSt
			INNER JOIN TicketSubtype AS ts
			ON LOWER(ts.SubtypeName)= LOWER(tblSt.Name)
        
    END;