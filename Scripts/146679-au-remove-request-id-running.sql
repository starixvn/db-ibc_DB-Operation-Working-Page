/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20201207@Carlos.Nguyen
Task :  Clear Running LA Auto Assignment Process
DB: bodb_OWP	

Revisions:
	 20201207@Carlos.Nguyen: Clear Running LA Auto Assignment Process - [Redmine: #146679]
*/


SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

DELETE FROM AutoAssignmentRequest
	WHERE RequestId IN ('4b0158b4-a32a-44e9-af00-5facdc2453d6', '7a5e4f1f-28a8-426f-a39d-296571f1e244')
	
	/* Remove assignment to this request*/
DELETE FROM AutoAssignmentResult
	WHERE RequestId IN ('4b0158b4-a32a-44e9-af00-5facdc2453d6', '7a5e4f1f-28a8-426f-a39d-296571f1e244')



