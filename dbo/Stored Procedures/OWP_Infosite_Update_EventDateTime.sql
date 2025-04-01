USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_Infosite_Update_EventDateTime]    Script Date: 4/2/2025 10:40:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_Infosite_Update_EventDateTime] @InfoSiteId INT,
@NewEventDate DATETIME
AS

/*
 Created: 20250210@Los
 Task : Correct game date
 DB: bodb_OWP

 Revisions:
	20250210@Los: Correct game date - [Feature: #222385]

*/

     SET NOCOUNT ON;

	 INSERT INTO InfositeLogs(CreatedDate,[Action],
	[Payload]) 
	SELECT DATEADD(HOUR, 12, GETDATE()),
	'UpdateEventDateTime_InfositeMatch',
	'{"OldValue": "' + CONVERT(NVARCHAR(19), EventDateTime, 120) + '", ' +
            '"NewValue": "' + CONVERT(NVARCHAR(19), @NewEventDate, 120) + '", ' +
            '"InfoSiteId": "' + CAST(@InfoSiteId AS NVARCHAR) + '"}'
	FROM InfoSiteMatch WITH (NOLOCK)
     WHERE InfoSiteMatchId=@InfoSiteId

	  UPDATE InfoSiteMatch WITH (ROWLOCK)
	 SET EventDateTime=@NewEventDate
	 WHERE InfoSiteMatchId=@InfoSiteId
