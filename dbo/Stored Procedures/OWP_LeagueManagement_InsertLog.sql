USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_LeagueManagement_InsertLog]    Script Date: 9/25/2025 2:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LeagueManagement_InsertLog] @SettingId			INT, 
                                                          @ModifiedBy       VARCHAR(255), 
														  @CreatedDate		DATETIME,
														  @Action			VARCHAR(255), 
														  @Content			VARCHAR(MAX)
AS
/*      
 Created: 20250924@Frankie
 Task : Get log league management
 DB: bodb_OWP      
 
 Revisions:
    20520924@Frankie: Init SP get log - [Redmine: #190039]
*/

    BEGIN
        SET NOCOUNT ON;

		INSERT INTO [LeagueSettingLog]
			([CreatedDate], 
			 [ModifiedBy], 
			 [SettingId], 
			 [Action], 
			 [Content]
			)
		VALUES 
			(@CreatedDate,
			 @ModifiedBy,
			 @SettingId,
			 @Action,
			 @Content
			)
    END;