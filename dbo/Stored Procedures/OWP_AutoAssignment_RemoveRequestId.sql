USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_AutoAssignment_RemoveRequestId]    Script Date: 10/02/2020 16:07:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_AutoAssignment_RemoveRequestId]
	@RequestId VARCHAR(MAX)
AS
/*
Created: 20200210@Carlos.Nguyen
Task : Remove request
DB: bodb_OWP

Revisions:
	20200210@Carlos.Nguyen: Initial SP - [Redmine: #126964]
*/

BEGIN
	SET NOCOUNT ON
	
	/* Remove request by id */
	DELETE FROM AutoAssignmentRequest
	WHERE RequestId=@RequestId
	
	/* Remove assignment to this request*/
	DELETE FROM AutoAssignmentResult
	WHERE RequestId=@RequestId
END
