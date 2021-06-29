
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignmentResult_Insert] @RequestId               VARCHAR(50), 
                                                        @Status                  INT, 
                                                        @AutoAssignmentResultDoc NVARCHAR(MAX), 
                                                        @ErrCode                 INT OUTPUT, 
                                                        @ErrMsg                  NVARCHAR(50) OUTPUT
AS

/*
Created: 20181221@Raymond.Le
Task : Insert auto assignment result
DB: bodb_OWP

@Status values:
  Error: -1,
  Success: 0,
  Running: 1
  
Revisions:
	20181221@Raymond.Le: Initial SP - [Redmine: #106196]
	20190503@Leo.Vo: Save request when failure - [Redmine: #112737]
	20191015@Kane.Le: update statusCode - [Redmine: #121765]
	20200601@Carlos.Nguyen: Return ErrorCode, ErrorMessage - [Redmine: #124448]
	20200528@Carlos.Nguyen: Update status code for request last - [Redmine: #126964]
	20210511@Mira: Auto trader assignment - [Redmine: #132710]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        DECLARE @requestLast VARCHAR(255), @eventDateGetRequest DATE;
        SELECT TOP 1 @eventDateGetRequest = req.EventDate
        FROM AutoAssignmentRequest AS req WITH(NOLOCK)
        WHERE req.RequestId = @RequestId;
        SELECT TOP 1 @requestLast = req.RequestId
        FROM AutoAssignmentRequest AS req WITH(NOLOCK)
        WHERE req.EventDate = @eventDateGetRequest
        ORDER BY req.CreatedDate DESC;
        UPDATE dbo.AutoAssignmentRequest WITH(ROWLOCK)
          SET 
              [Status] = @Status, 
              ResponseDate = GETDATE()
        WHERE RequestId = @requestLast
              AND [Status] <> @Status;
        IF @@ROWCOUNT = 1
           AND @Status = 0 -- save result if success
            BEGIN
                EXEC sp_xml_preparedocument 
                     @idoc OUTPUT, 
                     @AutoAssignmentResultDoc;
                INSERT INTO dbo.AutoAssignmentResult
                (RequestId, 
                 [OWPMatchId], 
                 [Bettype], 
                 [UserId_LA], 
                 [UserId_FTHDP], 
                 [UserId_1HHDP], 
                 [UserId_FTOU], 
                 [UserId_1HOU], 
                 [StatusCode], 
                 [GroupName], 
                 [ExtraTime]
                )
                       SELECT @RequestId, 
                              [OWPMatchId], 
                              [Bettype], 
                              [UserId_LA], 
                              [UserId_FTHDP], 
                              [UserId_1HHDP], 
                              [UserId_FTOU], 
                              [UserId_1HOU], 
                              [StatusCode], 
                              [Group], 
                              [ExtraTime]
                       FROM OPENXML(@idoc, '/Root/Row', 1) WITH([OWPMatchId] INT, [Bettype] INT, [UserId_LA] INT, [UserId_FTHDP] INT, [UserId_1HHDP] INT, [UserId_FTOU] INT, [UserId_1HOU] INT, [StatusCode] INT, [Group] NVARCHAR(200), [ExtraTime] NVARCHAR(10));
                EXEC sp_xml_removedocument 
                     @idoc;
        END;
        SET @ErrCode = 0;
    END;