/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20240402@Johnny
Task : Add match assignees section for ticket
DB: bodb_OWP	

Revisions:
	20240402@Johnny: Init script - [Redmine: #202819]
*/

ALTER TABLE MatchInfo
ADD [Agent_EST]  NVARCHAR(2000), 
    [Remark_EST] NVARCHAR(2000), 
    [RemarkBy]   NVARCHAR(2000);
ALTER TABLE MatchInfo_Old
ADD [Agent_EST]  NVARCHAR(2000), 
    [Remark_EST] NVARCHAR(2000), 
    [RemarkBy]   NVARCHAR(2000);
	
INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           ('AssigneeType'
           ,4
           ,'Match Assignees'
           ,0)
GO


