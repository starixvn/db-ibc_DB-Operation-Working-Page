
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*

Created: 20230918@Mira
Task : LA KPI phase 2
DB: bodb_OWP	

Revisions:
	20230918@Mira: add table setting for LA level - [Redmine: #193488]
*/

-- create LATargetSetting table
CREATE TABLE [dbo].[LATargetSetting]
([Id]       [INT] IDENTITY(1, 1) NOT NULL, 
 [UserId]   [INT] NOT NULL, 
 [TargetId] [INT] NULL, 
 CONSTRAINT [PK_LATargetSetting] PRIMARY KEY CLUSTERED([Id] ASC)
 WITH(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [OWP_Data]
)
ON [OWP_Data];

-- insert level to RefResource
INSERT INTO [dbo].[RefResource]
([RefName], 
 [ResourceId], 
 [Value], 
 [Order]
)
VALUES
	('LaKpiLevel',1,'New',10),
	('LaKpiLevel',2,'Level D',20),
	('LaKpiLevel',3,'Level C',30),
	('LaKpiLevel',4,'Level B',40),
	('LaKpiLevel',5,'Level A',50)

-- initial data
CREATE TABLE #temp
(Username NVARCHAR(200), 
 Target    NVARCHAR(200),
);
INSERT INTO #temp
(Username, 
 Target
)
VALUES
('SLADAISY','Level B'),
('SLAALLY','Level B'),
('SLAHADEN','Level B'),
('SLAENIX','Level B'),
('SLASPIKE','Level B'),
('SLAKENGLEE','Level B'),
('SLAROBERT','Level B'),
('SLAANGELY','Level B'),
('SLAHILARY','Level B'),
('SLASILVA','Level B'),
('SLAHUSON','Level B'),
('SLAHANSON','Level B'),
('SLASIMBA','Level B'),
('SLAHARDY','Level B'),
('SLAANDREA','Level B'),
('SLAJENNY','Level B'),
('SLASUMI','Level B'),
('SLADENNIX','Level B'),
('SLASHARON','Level B'),
('SLAVINCENT','Level B'),
('SLAYANG','Level B'),
('SLAJAY','Level B'),
('SLAAILEE','Level B'),
('SLAWANBI','Level B'),
('SLACATALEYA','Level B'),
('SLAOZIL','Level B'),
('SLADRAVEN','Level B'),
('SLALUCIA','Level B'),
('SLATONYNGUYEN','Level B'),
('SLAHARRIS','Level B'),
('SLAKYO','Level B'),
('SLAHAZARD','Level B'),
('SLAEREN','Level B'),
('SLAPONY','Level B'),
('SLAHAOMARU','Level B'),
('SLAQuest','Level B'),
('SLAROSE','Level B'),
('SLALYNN','Level B'),
('SLATommy.tran','Level B'),
('SLAAlan','Level B'),
('SLAGallen','Level B'),
('SLABELLA','Level C'),
('SLALAHM','Level C'),
('SLAMicht','Level C'),
('SLAHirene','Level C'),
('SLASHIRLEY','Level C'),
('SLAShaowei','Level C'),
('SLANaultad','Level C'),
('SLALAATEE1','Level C'),
('SLAPhoenix','Level C'),
('SLAShen','Level C'),
('SLAKayjun','Level C'),
('SLADan','Level C'),
('SLAKENNY','Level C'),
('SLAMANGO','Level C'),
('SLAPUIPUI','Level C'),
('SLAEDISON','Level C'),
('SLARAYMOND','Level C'),
('SLARAIN','Level C'),
('SLASAMMY','Level C'),
('SLASUNNY','Level C'),
('SLATANK','Level C'),
('SLABOSCO','Level C'),
('SLABILLY','Level C'),
('SLAKEITY','Level C'),
('SLAlUNA','New');

INSERT INTO [dbo].[LATargetSetting]
([UserId], 
 [TargetId]
)
       SELECT u.UserId, 
              r.ResourceId
       FROM #temp t
            INNER JOIN [User] u WITH(NOLOCK) ON u.Username = t.Username
            LEFT JOIN RefResource r WITH(NOLOCK) ON r.RefName = 'LaKpiLevel'
                                                    AND r.Value = t.Target
       ORDER BY t.Target;

-- drop temp table
DROP TABLE #temp;