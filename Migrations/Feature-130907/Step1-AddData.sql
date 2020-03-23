/*
	Created: Tyler.Dang
	Date: 20200323
	Task:  Add user locations for Covid19 [Redmine: #130907]
	DB: bodb_OWP
*/
USE bodb_OWP;
GO

UPDATE [dbo].[RefResource] SET [Value] = N'WAH HCMC' WHERE [RefName] = N'LocationCode' AND [ResourceId] = 3;

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LocationCode'
           ,4
           ,N'WAH MAL'
           ,0)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LocationCode'
           ,5
           ,N'WAH MNL'
           ,0)
GO

