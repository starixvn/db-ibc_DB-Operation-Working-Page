/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20231219@Liam
Task : add ordered league group
DB: bodb_OWP

Revisions:
	20231219@Liam: Init script - [Redmine: #198232]
*/


CREATE TABLE #tempLeagueGroup
(LeagueGroupName       NVARCHAR(MAX), 
 OrderValue INT
);

-- Insert data into the temporary table
INSERT INTO #tempLeagueGroup
(LeagueGroupName, 
 OrderValue
)
VALUES
('World Cup', 
 1
),
('EURO', 
 2
),
('MJ', 
 3
),
('INT.MJ', 
 4
),
('MJ.T1', 
 5
),
('MJ.T2', 
 6
),
('CL.MJ.Q', 
 7
),
('M1', 
 8
),
('Others 1', 
 9
),
('M2', 
 10
),
('Others 2', 
 11
),
('INT.MN', 
 12
),
('M3', 
 13
),
('Others 3', 
 14
),
('M4', 
 15
),
('Others 4', 
 16
),
('Others 5', 
 17
),
('CL.MN.Q', 
 18
),
('Others', 
 19
);


UPDATE RefResource
  SET 
      [Order] = temp.OrderValue
FROM RefResource ref
     INNER JOIN #tempLeagueGroup temp ON ref.[Value] = temp.LeagueGroupName
                                         AND ref.RefName = 'LeagueCategory';
DROP TABLE #tempLeagueGroup;


