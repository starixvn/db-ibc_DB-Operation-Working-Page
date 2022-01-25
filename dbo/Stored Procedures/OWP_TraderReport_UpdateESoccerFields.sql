
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

        -- Update Data
        UPDATE r
          SET 
              r.ESoccer_5Mins = t.ESoccer5Mins, 
              r.ESoccer_6Mins = t.ESoccer6Mins, 
              r.ESoccer_15Mins = t.ESoccer15Mins, 
              r.ESoccer_16Mins = t.ESoccer16Mins, 
              r.ESoccer_20Mins = t.ESoccer20Mins
        FROM dbo.TraderReport AS r
             INNER JOIN #tmpTable t ON r.UserId = t.UserId
                                       AND r.ReportDate = @EventDate;

        -- Drop temp table
        DROP TABLE #tmpTable;
    END;