
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetMessageTemplateByCode] (@MessageTemplateCode NVARCHAR(100))
	RETURNS TABLE
/*
Created: Carlos.Nguyen@20180821
Task: Replace template message when update matchsetting
DB: bodb_OWP

Param's Explanation:
Revisions:
	20180821@Carlos.Nguyen: Initial SP - [Redmine: #118856]
*/
AS RETURN (SELECT mt.MsgTemplateContent, mt.MsgTemplateId
			FROM MessageTemplate AS mt WITH(NOLOCK)
			WHERE mt.MsgTemplateCode=@MessageTemplateCode)