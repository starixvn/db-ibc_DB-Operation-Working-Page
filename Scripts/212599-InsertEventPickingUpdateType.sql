/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20241104@Oliver.Dang
Task : Insert new event picking update type
DB: bodb_OWP

Revisions:
    20241104@Oliver.Dang: Insert new event picking update type - [Redmine: #212599]
*/

INSERT INTO [dbo].[EventPickingUpdateType]
           ([Id]
           ,[UpdateType]
           ,[RAndDUpdate])
     VALUES
           (24
           ,'Move KO Date'
           ,'Move KO Date'),
		   (25
           ,'Renew Match'
           ,'Renew Match')
GO


