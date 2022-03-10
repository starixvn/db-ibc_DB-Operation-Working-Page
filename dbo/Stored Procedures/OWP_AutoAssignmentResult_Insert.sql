USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignmentResult_Insert]    Script Date: 03/09/2022 14:29:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
	20211213@Carlos: Auto enhance auto assignment - [Redmine: #163362]
	20220105@Liam.Pham: Auto assignment time table - [Redmine: #166161]
	20220310@Carlos.nguyen: get request new - [Redmine: #163362]
	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        
        UPDATE dbo.AutoAssignmentRequest WITH(ROWLOCK)
          SET 
              [Status] = @Status, 
              ResponseDate = GETDATE()
        WHERE RequestId = @RequestId
              AND [Status] <> @Status;
             
        IF @Status = 0 -- save result if success
            BEGIN
                EXEC sp_xml_preparedocument 
                     @idoc OUTPUT, 
                     @AutoAssignmentResultDoc;
                INSERT INTO dbo.InfoSiteAutoAssignmentResult
                (RequestId, 
                 [InfoSiteMatchId], 
                 [Bettype],
                 [IsSaba],
                 [IsFutsal],
                 [PcCode],
                 [UserId_LA], 
                 [UserId_FTHDP], 
                 [UserId_1HHDP], 
                 [UserId_FTOU], 
                 [UserId_1HOU], 
                 [StatusCode], 
                 [Group], 
                 [ExtraTime],
                 [SabaType],
				 [GroupTrader]
                )
                       SELECT @RequestId, 
                              [MatchId], 
                              [Bettype],
                              [IsSaba],
							  [IsFutsal],
							  [PcCode],
                              [UserId_LA], 
                              [UserId_FTHDP], 
                              [UserId_1HHDP], 
                              [UserId_FTOU], 
                              [UserId_1HOU], 
                              [StatusCode], 
                              [Group], 
                              [ExtraTime],
                              [SabaType],
							  [GroupTrader]
                       FROM OPENXML(@idoc, '/Root/AssignmentResult', 1) WITH(
                       [MatchId] INT,
                       [Bettype] INT,
                       [IsSaba] BIT,
					   [IsFutsal] BIT,
					   [PcCode] NVARCHAR(2000),
                       [UserId_LA] INT,
                       [UserId_FTHDP] INT,
                       [UserId_1HHDP] INT,
                       [UserId_FTOU] INT,
                       [UserId_1HOU] INT,
                       [StatusCode] INT,
                       [Group] NVARCHAR(200),
                       [ExtraTime] NVARCHAR(10),
                       [SabaType] INT,
					   [GroupTrader]NVARCHAR(200)
                       );
                EXEC sp_xml_removedocument 
                     @idoc;
                  
        END;
        SET @ErrCode = 0;
    END;
