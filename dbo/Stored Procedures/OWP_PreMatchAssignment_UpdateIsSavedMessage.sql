
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_UpdateIsSavedMessage] @PreMatchIssueMessageId INT, 
                                                                    @IsSaved                BIT
AS

/*
Created: 20210113@Mira
Task : Save message in chat board
DB: bodb_OWP

Revisions:
	20210113@Mira: Init SP - [Redmine: #148266]

*/

    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.[PreMatchIssueMessage] WITH(ROWLOCK)
          SET 
              IsSaved = @IsSaved
        WHERE PreMatchIssueMessageId = @PreMatchIssueMessageId;
    END;