
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_DeleteUnSavedIssueMessage]
AS

/*
Created: 20210114@Mira
Task : Save message in chat board
DB: bodb_OWP

Revisions:
	20210114@Mira: Init SP - [Redmine: #148266]

*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @Today DATE= GETDATE();
        DECLARE @LatestDate INT= 7;
        DECLARE @MarkDate DATETIME= DATEADD(DAY, -@LatestDate, @Today);

        --delete
        DELETE FROM dbo.[PreMatchIssueMessage]
        WHERE CreatedDate < @MarkDate
              AND (IsSaved = 0
                   OR IsSaved IS NULL);
    END;