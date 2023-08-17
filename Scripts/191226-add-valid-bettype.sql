
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20230817@Mira
Task : Child match AIO
DB: bodb_OWP	

Revisions:
	20230817@Mira: add more valid bettype [Redmine: #191226]
*/

-- allow identity insert
SET IDENTITY_INSERT [dbo].[MinorBettype] ON;

-- Delete invalid bettype
DELETE FROM dbo.MinorBettype
WHERE MinorBettypeId BETWEEN(-258) AND(-112);

-- Add more valid bettype
INSERT INTO [dbo].[MinorBettype]
           ([MinorBettypeId]
		   ,[MinorBettypeName]
           ,[ParentBettypeId]
           ,[InheritedBettypeId]
           ,[Alias]
           ,[IsActive]
           ,[IsMinorBettype]
           ,[SortOrder])
     VALUES
           (-188,'Fast Market Total Of Bookings',null,null,null,1,1,null),
		   (-189,'All In One Total Of Bookings',null,null,null,1,1,null),
           (-288,'Fast Market Number Of Corners',null,null,null,1,1,null),
           (-289,'All In One Number Of Corners',null,null,null,1,1,null);