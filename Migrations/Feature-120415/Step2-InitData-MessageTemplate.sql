INSERT INTO dbo.MessageTemplate (
	MsgTemplateId
	,MsgTemplateCode
	,MsgTemplateContent
	,SystemMessageType
	)
VALUES (
	41
	,'AssignmentDeleteDeselectedMatch'
	,'Your assignment has been REMOVED for the match <Match.No> - <League> -  <Event> updated by <User>'
	,1
	)

INSERT INTO dbo.MessageTemplate (
	MsgTemplateId
	,MsgTemplateCode
	,MsgTemplateContent
	,SystemMessageType
	)
VALUES (
	42
	,'AssignmentNoteDeleteDeselectedMatch'
	,'Your assignment has been REMOVED <Note>  for the match: <Match.No> - <League> -  <Event> updated by <User>'
	,1
	)
