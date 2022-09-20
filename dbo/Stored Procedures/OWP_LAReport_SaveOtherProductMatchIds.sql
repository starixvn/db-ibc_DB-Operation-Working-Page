
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LAReport_SaveOtherProductMatchIds] @EventDate   DATE, 
                                                               @OWPMatchIds VARCHAR(MAX)
AS

/*
Created: 20220920@Mira
Task : LA report enhancement
DB: bodb_OWP	

Revisions:
	20220920@Mira: Init SP - [Redmine: #177768]
*/

    BEGIN
        SET NOCOUNT ON;
        IF EXISTS
        (
            SELECT 1
            FROM dbo.LAReportOthersProduct
            WHERE ReportDate = @EventDate
        )
            BEGIN
                UPDATE dbo.LAReportOthersProduct
                  SET 
                      OWPMatchIds = @OWPMatchIds
                WHERE ReportDate = @EventDate;
        END;
            ELSE
            BEGIN
                INSERT INTO dbo.LAReportOthersProduct
                (ReportDate, 
                 OWPMatchIds
                )
                VALUES
                (@EventDate, 
                 @OWPMatchIds
                );
        END;
    END;