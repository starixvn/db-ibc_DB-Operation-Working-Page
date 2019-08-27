USE [bodb_OWP]
GO

INSERT INTO [dbo].[MessageTemplate]
           ([MsgTemplateId]
		   ,[MsgTemplateCode]
           ,[MsgTemplateContent]
           ,[SystemMessageType])
     VALUES
           (35
		   ,'EditInfoSiteMatchId'
           ,'Was updated InfoSiteId: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
           ,1)
GO

INSERT INTO [dbo].[MessageTemplate]
           ([MsgTemplateId]
		   ,[MsgTemplateCode]
           ,[MsgTemplateContent]
           ,[SystemMessageType])
     VALUES
           (36
		   ,'EditWebsite1'
           ,'Was updated Website1: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
           ,1)
GO

INSERT INTO [dbo].[MessageTemplate]
           ([MsgTemplateId]
		   ,[MsgTemplateCode]
           ,[MsgTemplateContent]
           ,[SystemMessageType])
     VALUES
           (37
		   ,'EditWebsite2'
           ,'Was updated Website2: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
           ,1)
GO

INSERT INTO [dbo].[MessageTemplate]
           ([MsgTemplateId]
		   ,[MsgTemplateCode]
           ,[MsgTemplateContent]
           ,[SystemMessageType])
     VALUES
           (38
		   ,'EditWebsite3'
           ,'Was updated Website3: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
           ,1)
GO

INSERT INTO [dbo].[MessageTemplate]
           ([MsgTemplateId]
		   ,[MsgTemplateCode]
           ,[MsgTemplateContent]
           ,[SystemMessageType])
     VALUES
           (39
		   ,'EditWebsite4'
           ,'Was updated Website4: [ <New> ]  for the match: <Match.No> - <League> - <Event> updated by <User>, previous: [ <Old> ]'
           ,1)
GO

