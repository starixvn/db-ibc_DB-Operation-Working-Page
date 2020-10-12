/*
	Created: Tyler.Dang
	Date: 20200323
	Task:  Add WAH location [Redmine: #129397]
	DB: bodb_OWP
*/
USE bodb_OWP;
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LocationCode'
           ,3
           ,N'WAH'
           ,0)
GO