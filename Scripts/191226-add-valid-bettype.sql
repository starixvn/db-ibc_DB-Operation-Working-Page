
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
([MinorBettypeId], 
 [MinorBettypeName], 
 [ParentBettypeId], 
 [InheritedBettypeId], 
 [Alias], 
 [IsActive], 
 [IsMinorBettype], 
 [SortOrder]
)
VALUES
    (-188,'Fast Market Total Of Bookings',null,null,null,1,1,null),
	(-189,'All In One Total Of Bookings',null,null,null,1,1,null),
    (-288,'Fast Market Number Of Corners',null,null,null,1,1,null),
    (-289,'All In One Number Of Corners',null,null,null,1,1,null);

-- don't allow identity insert
SET IDENTITY_INSERT [dbo].[MinorBettype] OFF;

-- Add more MinorMatchTemplateSetting
INSERT INTO [dbo].[MinorMatchTemplateSetting]
([MinorBettypeId], 
 [League], 
 [Home], 
 [Away], 
 [IsRepresented], 
 [IsActive]
)
VALUES
	(-188,'<name> - FAST MARKET BOOKING','<name> Total Of Bookings Fast Market','<name> Total Of Bookings Fast Market',1,1),
	(-189,'<name> - ALL IN ONE BOOKING','<name> Total Of Bookings All In One','<name> Total Of Bookings All In One',1,1),
	(-288,'<name> - FAST MARKET NUMBER OF CORNERS','<name> No.of Corners Fast Market','<name> No.of Corners Fast Market',1,1),
	(-289,'<name> - ALL IN ONE NUMBER OF CORNERS','<name> No.of Corners All In One','<name> No.of Corners All In One',1,1);
