/*
	Created: Carlos.Nguyen
	Date: 20191011
	Task: alter data [Redmine: #121885]
	DB: bodb_OWP
*/

USE bodb_OWP
GO

-- transform note to remark
INSERT INTO dbo.[UserRemark] (UserId, Remark, Category)
SELECT UserId, Note, 1
FROM dbo.[EmployeeWorkingShiftNote_Old] WITH (NOLOCK)
GO


-- add user group
INSERT INTO dbo.RefResource(RefName, ResourceId, Value, [Order])
VALUES ('UserGroup',1,'C_LG',1),
	('UserGroup',2,'C_LG(Special Team)',2),
	('UserGroup',3,'C_LG(Support Team)',3),
	('UserGroup',4,'S_LG',4),
	('UserGroup',5,'S_LG(Special Team)',5),
	('UserGroup',6,'SUPPORT TEAM',6)
GO

-- log action
UPDATE dbo.LogAction
SET LogItems='<root><xml path="r/z" />
		<row item="FullName" alias="fn" />
		<row item="NickName" alias="nn" />
		<row item="EmployeeId" alias="eid" />
		<row item="CategoryId" alias="ca" />
		<row item="Extension" alias="ex" />
		<row item="Phone" alias="p" />
		<row item="Email" alias="e" />
		<row item="Skype" alias="s" />
		<row item="DepartmentId" alias="d" />
		<row item="SectionId" alias="sec" />
		<row item="GroupId" alias="grp" />
		<row item="RoleId" alias="r" />
		<row item="LocationCode" alias="lo" />
		</root>'
WHERE SPName='OWP_UserUpdate'

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES (29, 'UserRemark', 7)

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (99, 7 ,29 ,2 ,'OWP_EmployeeWorkingShift_UpdateRemark' ,'OWP_EmployeeWorkingShift_UpdateRemark' ,'<root><xml path="r/z" /><row item="Category" alias="ca" /><row item="Remark" alias="rm" /></root>')

UPDATE dbo.LogAction
SET LogItems='<root><xml path="r/z" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="CreatedBy" alias="cb" /></root>'
WHERE SPName='OWP_EmployeeWorkingShift_UpdateNote'

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (100, 7 ,25 ,1 ,'OWP_EmployeeWorkingShift_InsertNote' ,'OWP_EmployeeWorkingShift_InsertNote' ,'<root><xml path="r/z" /><row item="UserId" alias="ui" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="ShiftDate" alias="sd" /></root>')

INSERT INTO dbo.LogAction (ActionId	,ModuleId ,[ModuleObjectId]	,[ActionTypeId]	,[ActionName] ,[SPName]	,[LogItems])
VALUES (101, 7 ,25 ,3 ,'OWP_EmployeeWorkingShift_DeleteNote' ,'OWP_EmployeeWorkingShift_DeleteNote' ,'<root><xml path="r/z" /><row item="CreatedDate" alias="cd" /><row item="Note" alias="nt" /><row item="CreatedBy" alias="cb" /><row item="ShiftDate" alias="sd" /><row item="UserId" alias="ui" /></root>')

GO

-- update user group
UPDATE u
SET u.GroupId = 1
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'CLGAaron'
,'CLGAIK'
,'CLGAlikin'
,'CLGBoonlay'
,'CLGCam'
,'CLGCandy'
,'CLGChang'
,'CLGChee'
,'CLGChun'
,'CLGCkeen'
,'CLGDaniel'
,'CLGDexter'
,'CLGDodo'
,'CLGDucan'
,'CLGDuy'
,'CLGEdwen'
,'CLGEven'
,'CLGFai'
,'CLGGary'
,'CLGGillian'
,'CLGHan'
,'CLGYew'
,'CLGHendra'
,'CLGHoo'
,'CLGHonsang'
,'CLGHuat'
,'CLGIndo'
,'CLGJack'
,'CLGJacky'
,'CLGJon'
,'CLGJoseph'
,'CLGKelven'
,'CLGKentham'
,'CLGKern'
,'CLGKien'
,'CLGKit'
,'CLGKokchen'
,'CLGKuik'
,'CLGLee'
,'CLGLim'
,'CLGLouis'
,'CLGManzai'
,'CLGMarco'
,'CLGMichelle'
,'CLGNeo'
,'CLGNhi'
,'CLGNicky'
,'CLGNikkol'
,'CLGParker'
,'CLGPeng1'
,'CLGPing'
,'CLGRino'
,'CLGRobin'
,'CLGRuby'
,'CLGRyan'
,'CLGSaelee'
,'CLGSan'
,'CLGSandy'
,'CLGSeang'
,'CLGSern'
,'CLGShuan'
,'CLGSiang'
,'CLGSusan'
,'CLGTeck'
,'CLGTeckkeong'
,'CLGTeckping'
,'CLGTommy'
,'CLGTommylim'
,'CLGVico'
,'CLGWai'
,'CLGWen'
,'CLGXavi'
,'CLGYamy'
,'CLGYing'
,'CLGYuan'
,'CLGKilos'
);

UPDATE u
SET u.GroupId = 2
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'CLGBay'
,'CLGEdy'
,'CLGGreen'
,'CLGIvan'
,'CLGLukeyap'
,'CLGMan88'
,'CLGPeter'
,'CLGPiew'
,'CLGTony'
,'CLGTonykho'
,'CLGYao'
);

UPDATE u
SET u.GroupId = 3
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'CLGBoon'
,'CLGKenji'
,'CLGShootbird'
,'CLGChai'
,'CLGChian'
,'CLGGee'
,'CLGRaymond'
,'CLGTeoh');

UPDATE u
SET u.GroupId = 4
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'SLGAlbert'
,'SLGASoon'
,'SLGBaron'
,'SLGBen'
,'SLGBou'
,'SLGBoy'
,'SLGCalvin'
,'SLGChris'
,'SLGCory'
,'SLGGoh'
,'SLGHanwei'
,'SLGJanet'
,'SLGJeffrey'
,'SLGJenny'
,'SLGJiaming'
,'SLGJulie'
,'SLGKenHong'
,'SLGKris'
,'SLGLina'
,'SLGLMax'
,'SLGMing'
,'SLGNarsi'
,'SLGOscar'
,'SLGPlang'
,'SLGRandy'
,'SLGTheeng'
,'SLGTom'
,'SLGTylen'
,'SLGWanjie'
,'SLGWubai'
,'SLGYen'
);

UPDATE u
SET u.GroupId = 5
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'SLGDickson'
,'SLGKarson'
,'SLGLuke'
);

UPDATE u
SET u.GroupId = 6
FROM dbo.[User] AS u WITH(ROWLOCK,UPDLOCK)
WHERE u.Username  IN (
'SMTDLKarinna'
,'SMTDLHenry'
,'SMTDLPatrick'
,'SMTDLNesta'
,'SMTDLCarson'	
,'SMTDLKenson'	
,'SMTDLZon'	
,'SMTDLShady'	
,'SMTDLNelson'	
,'SMTDLLuka'	
,'SMTDLBolly'	
,'SMTDLTerrance'	
,'SMTDLMeena'	
,'SMTDLALexlam'	
,'SMTDLGloria'	
,'SMTDLKevin'	
,'SMTDLLogan'	
,'SMTDLJames'	
,'SMTDLVICTOR'	
,'SMTDLEnzo'	
,'SMTDLMESSI'	
,'SMTDLRicky'	
,'SMTDLKELLY'	
,'SMTDLADRA'	
,'SMTDLMata'	
,'SMTDLKENNETH'	
,'SMTDLHubert'	
,'SDAFEI'
,'SDAFRANK'	
,'SDAKID'
,'SDAKENT'	
,'SDAWoody'	
,'SDAPANDA'	
,'SDAEDAN'
,'SDARioWong'
,'SDALoi'
,'SLAFATTCHAI'	
,'SESTFUNG'	
,'SESTBAO'
,'SESTCHEONG'	
,'SESTHORNG'	
,'SESTYUNG'	
,'SESTCHIN'	
,'SESTLOON'	
,'Pau'	
,'Siong'	
,'Weng'
,'SOIIONN'	
,'SOIIYAP'	
,'CNSDBeng'	
,'CNSDChuan'	
,'CNSDTai'	
,'SPHAnnie'	
,'SPHKatie'	
,'SPHJoy'
,'SPHBritney'	
,'SPHTevez'	
,'SPHDallas'	
,'SPHSeven'
,'SPHSheamus'	
,'SPHLucas'	
,'SPHTerry'	
,'SPHKarla'	
,'SPHHana'
,'SPHCrystal'	
,'SPHNJay'	
,'SPHLevi'	 
,'SPHDante'	 
,'SPHEtolu'	 
,'SPHSharly'	 
,'SPHMarvin'	 
,'SPHRory'	 
,'SPHEason'	 
,'SPHShelly'	 
,'SPHNike'	 
,'SPHBenny'	 
,'SPHRayon'	 
,'SPHJolie'	 
,'SPHSteven'	 
,'SPHTaemi'	 
,'SPHLucy'	 
,'SPHBill'	 
,'SPHHoliday'	 
,'SPHBert'	 
,'SPHBobby'	 
,'SPHBoston');
GO