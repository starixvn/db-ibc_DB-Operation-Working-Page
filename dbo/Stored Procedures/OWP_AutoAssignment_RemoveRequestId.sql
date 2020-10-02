USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_WriteHistorySuspender]    Script Date: 09/24/2020 09:58:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_AutoAssignment_WriteHistorySuspender]
	@SuspenderHistoryDoc NVARCHAR(MAX)
AS
/*
Created: 20200528@Carlos.Nguyen
Task : Write history suspender
DB: bodb_OWP

Revisions:
	20200528@Carlos.Nguyen: Initial SP - [Redmine: #126964]
	20200918@Carlos.Nguyen: Auto reassign - [Redmine: #126964]
*/

BEGIN
	SET NOCOUNT ON
	
	DELETE AutoAssignmentSuspenderHistory
	
	DECLARE @idoc INT
	
	EXEC sp_xml_preparedocument @idoc OUTPUT
			,@SuspenderHistoryDoc

	INSERT INTO AutoAssignmentSuspenderHistory
	(
		UserId,
		InTime,
		OutTime,
		SpeakChinese,
		SpeakEnglish
	)
		SELECT UserId,
			InTime,
			OutTime,
			SpeakChinese,
			SpeakEnglish
		FROM OPENXML(@idoc, '/Root/Row', 1)
			WITH (UserId [int], InTime VARCHAR(500), OutTime VARCHAR(500), SpeakChinese [BIT],SpeakEnglish [BIT])

		EXEC sp_xml_removedocument @idoc
END
