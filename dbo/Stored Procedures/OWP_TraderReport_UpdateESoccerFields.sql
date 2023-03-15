
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReport_UpdateESoccerFields] @EventDate        DATETIME, 
                                                             @ESoccerFieldsXml NVARCHAR(MAX)
AS

/*    
 Created: 20220119@Mira
 Task : Trader Report
 DB: bodb_OWP    
    
 Revisions:
	20220119@Mira: Add SABA Soccer into Trader report - [Redmine: #167636]	
	20230301@Los: Insert or update - [Redmine: #184170]
*/

    BEGIN
        SET NOCOUNT ON;
        -- Parameters
        CREATE TABLE #tmpTable
        (UserId        INT, 
         ESoccer5Mins  INT, 
         ESoccer6Mins  INT, 
         ESoccer15Mins INT, 
         ESoccer16Mins INT, 
         ESoccer20Mins INT
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @ESoccerFieldsXml;
        INSERT INTO #tmpTable
               SELECT UserId, 
                      ESoccer5Mins, 
                      ESoccer6Mins, 
                      ESoccer15Mins, 
                      ESoccer16Mins, 
                      ESoccer20Mins
               FROM OPENXML(@idoc, '/Root/ESoccerByUser', 1) WITH(UserId INT, ESoccer5Mins INT, ESoccer6Mins INT, ESoccer15Mins INT, ESoccer16Mins INT, ESoccer20Mins INT);
        EXEC sp_xml_removedocument 
             @idoc;
        
        MERGE dbo.TraderReport AS TARGET
        USING #tmpTable AS SOURCE
        ON(TARGET.UserId = SOURCE.UserId
           AND CAST(TARGET.ReportDate AS DATE) = @EventDate)
            WHEN MATCHED AND TARGET.UserId = SOURCE.UserId
                             AND CAST(TARGET.ReportDate AS DATE) = @EventDate
            THEN UPDATE SET 
                            TARGET.ESoccer_5Mins = SOURCE.ESoccer5Mins, 
                            TARGET.ESoccer_6Mins = SOURCE.ESoccer6Mins, 
                            TARGET.ESoccer_15Mins = SOURCE.ESoccer15Mins, 
                            TARGET.ESoccer_16Mins = SOURCE.ESoccer16Mins, 
                            TARGET.ESoccer_20Mins = SOURCE.ESoccer20Mins
            WHEN NOT MATCHED BY TARGET
            THEN
              INSERT(ReportDate, 
                     UserId, 
                     ESoccer_5Mins, 
                     ESoccer_6Mins, 
                     ESoccer_15Mins, 
                     ESoccer_16Mins, 
                     ESoccer_20Mins, 
                     CreatedDate)
              VALUES
        (@EventDate, 
         SOURCE.UserId, 
         SOURCE.ESoccer5Mins, 
         SOURCE.ESoccer6Mins, 
         SOURCE.ESoccer15Mins, 
         SOURCE.ESoccer16Mins, 
         SOURCE.ESoccer20Mins, 
         GETDATE()
        );
        UPDATE t
          SET 
              t.Username = u.Username
        FROM TraderReport t
             INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = t.UserId
        WHERE t.Username IS NULL;

        -- Drop temp table
        DROP TABLE #tmpTable;
    END;