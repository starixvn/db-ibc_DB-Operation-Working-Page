
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_OvertimeReport_SaveOvertimeReport] @EventDate DATE, 
                                                               @Data      NVARCHAR(MAX)
AS

/*    
Created: 20211014@Tyler
Task : Overtime Report
DB: bodb_OWP

Revisions:
	20211014@Tyler: init sp - [Redmine: #162821]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tmpData TABLE
        (UserId     INT, 
         ReportDate DATETIME, 
         [Hour]     DECIMAL(4, 2), 
         IsOffDay   BIT
        );
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @Data;
        INSERT INTO @tmpData
               SELECT DISTINCT 
                      UserId, 
                      ReportDate, 
                      [Hour], 
                      IsOffDay
               FROM OPENXML(@idoc, '/Root/OvertimeData', 1) WITH(UserId INT, ReportDate DATETIME, [Hour] DECIMAL(4, 2), IsOffDay BIT);
        EXEC sp_xml_removedocument 
             @idoc;

        -- DELETE if exists
        DELETE o
        FROM dbo.OvertimeReport o
        WHERE o.ReportDate = @EventDate;

        -- INSERT
        INSERT INTO dbo.OvertimeReport
        (ReportDate, 
         UserId, 
         [Hour], 
         IsOffDay
        )
               SELECT ReportDate, 
                      UserId, 
                      [Hour], 
                      IsOffDay
               FROM @tmpData;
    END;