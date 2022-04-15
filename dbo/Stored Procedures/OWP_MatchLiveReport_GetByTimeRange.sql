
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MatchLiveReport_GetByTimeRange] @FromDate DATE, @ToDate DATE

/*      
 Created: 20220401@carlos.nguyen
 Task : Get match report in time range
 DB: bodb_OWP      
      
Revisions:  
	20220401@carlos.nguyen: Initial SP - [Redmine: #170737]  
	
*/

AS
	
	DECLARE @matchCount TABLE(
		[Order] INT,
		[No] INT,
		[BetType] [nvarchar](100) NOT NULL,
		[IsSaba] BIT,
		[Mj] INT,
		[M1] INT,
		[M2] INT,
		[M3] INT,
		[M4] INT,
		[Others] INT,
		[Others1] INT,
		[Others2] INT,
		[Others3] INT,
		[Others4] INT,
		[Others5] INT,
		[Others6] INT,
		[Unknown] INT
	)
	
	DECLARE @result TABLE(
		[Order] INT,
		[No] INT,
		[BetType] [nvarchar](100) NOT NULL,
		[Total] INT,
		[IsSaba] BIT,
		[Mj] INT,
		[M1] INT,
		[M2] INT,
		[M3] INT,
		[M4] INT,
		[Others] INT,
		[Others1] INT,
		[Others2] INT,
		[Others3] INT,
		[Others4] INT,
		[Others5] INT,
		[Others6] INT,
		[Unknown] INT
	)
	
	DECLARE @bettype TABLE(
		[Order] [int] IDENTITY(1,1) NOT NULL,
		[No] INT,
		[BetType] [nvarchar](100) NOT NULL,
		[IsSaba] BIT
	)
	
	INSERT INTO @bettype ([No], [BetType], [IsSaba]) VALUES
	(NULL,'Real Soccer', 0),
	(1,'Main', 0),
	(2,'Corners', 0),
	(3,'Next corners', 0),
	(4,'Last corners', 0),
	(5,'15 mins Corners', 0),
	(6,'15 mins (4 quarters)', 0),
	(7,'10 mins (6 quarters)', 0),
	(8,'Bookings', 0),
	(9,'Next bookings', 0),
	(10,'15 mins bookings', 0),
	(11,'Last bookings', 0),
	(12,'Winner', 0),
	(13,'Special goal', 0),
	(14,'Single Team Home/Away (2 events)', 0),
	(15,'Fantasy Match', 0),
	(16,'1st Penalty To Score', 0),
	(17,'1st Penalty Awarded', 0),
	(18,'Free kick (2H 1st xxx)', 0),
	(19,'Throw In (2H 1st xxx)', 0),
	(20,'Offside (2H 1st xxx)', 0),
	(21,'Goal kick (2H 1st xxx)', 0),
	(22,'Last Free kick', 0),
	(23,'Last Throw In', 0),
	(24,'Last Goal kick', 0),
	(25,'Next Goal kick', 0),
	(26,'Penalty shoot out Home/Away (2 events)', 0),
	(27,'Which team to kick off (ET)', 0),
	(28,'Which team to take the first penalty', 0),
	(NULL,'SABA', 1),
	(1,'SABA CLUB FRIENDLY Virtual PES 21 - 15 Mins Play', 1),
	(2,'SABA INTERNATIONAL FRIENDLY Virtual PES 21 - 20 Mins Play', 1),
	(3,'SABA ELITE FRIENDLY Virtual PES 21 - 5 Mins Play', 1),
	(4,'M88 SABA SPANISH LEAGUE Virtual FIFA 21 Season 10 - 16 Mins Play', 1),
	(5,'SABA CLUB FRIENDLY Virtual FIFA 20 FUTSAL - 6 Mins Play', 1),
	(6,'SABA CLUB FRIENDLY Virtual FIFA 21 - 16 Mins Play', 1)
	
	
	INSERT INTO @matchCount(
		[BetType],
		[IsSaba],
		[Mj],
		[M1],
		[M2],
		[M3],
		[M4],
		[Others],
		[Others1],
		[Others2],
		[Others3],
		[Others4],
		[Others5],
		[Others6],
		[Unknown])
	SELECT
		ml.BetType,
		ml.IsSaba,
		CASE WHEN ml.LeagueCategory='MJ' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='M1' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='M2' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='M3' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='M4' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 1' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 2' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 3' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 4' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 5' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Others 6' THEN SUM(ml.MatchCount) ELSE 0 END,
		CASE WHEN ml.LeagueCategory='Unknown' THEN SUM(ml.MatchCount) ELSE 0 END
	FROM @bettype AS b
		INNER JOIN MatchLiveReport AS ml
	ON b.BetType=ml.BetType
	WHERE ml.EventDate BETWEEN @FromDate AND @ToDate
	GROUP BY ml.BetType, ml.LeagueCategory, ml.IsSaba
	
	--Count number league category each bettype--
	INSERT INTO @result(
		[BetType],
		[IsSaba],
		[Mj],
		[M1],
		[M2],
		[M3],
		[M4],
		[Others],
		[Others1],
		[Others2],
		[Others3],
		[Others4],
		[Others5],
		[Others6],
		[Unknown])
	SELECT r.BetType,
		r.IsSaba,
		SUM(r.Mj),
		SUM(r.M1),
		SUM(r.M2),
		SUM(r.M3),
		SUM(r.M4),
		SUM(r.[Others]),
		SUM(r.[Others1]),
		SUM(r.[Others2]),
		SUM(r.[Others3]),
		SUM(r.[Others4]),
		SUM(r.[Others5]),
		SUM(r.[Others6]),
		SUM(r.[Unknown])
	FROM @matchCount AS r
	GROUP BY r.BetType, r.IsSaba
	
	--Update total each bettype--
	UPDATE r
	SET r.Total=Mj+M1+M2+M3+M4+Others+Others1+Others2+Others3+Others4+Others5+Others6+Unknown
	FROM @result AS r

	--SUM real--
	INSERT INTO @result(
		BetType, 
		IsSaba,
		Total,
		Mj,
		M1,
		M2,
		M3,
		M4,
		Others,
		Others1,
		Others2,
		Others3,
		Others4,
		Others5,
		Others6,
		Unknown)
	SELECT
		'Real Soccer',
		0,
		SUM(r.Mj)+ SUM(r.M1)+ SUM(r.M2)+SUM(r.M3)+ SUM(r.M4)+ SUM(r.Others)+ SUM(r.Others1)+SUM(r.Others2)+SUM(r.Others3)+SUM(r.Others4)+SUM(r.Others5)+SUM(r.Others6)+SUM(r.Unknown),
		SUM(r.Mj),
		SUM(r.M1),
		SUM(r.M2),
		SUM(r.M3),
		SUM(r.M4),
		SUM(r.Others),
		SUM(r.Others1),
		SUM(r.Others2),
		SUM(r.Others3),
		SUM(r.Others4),
		SUM(r.Others5),
		SUM(r.Others6),
		SUM(r.Unknown)
	FROM @result AS r
	WHERE r.IsSaba=0 OR r.IsSaba IS NULL
	
	--Sum SABA--
	INSERT INTO @result(
		BetType, 
		IsSaba,
		Total,
		Mj,
		M1,
		M2,
		M3,
		M4,
		Others,
		Others1,
		Others2,
		Others3,
		Others4,
		Others5,
		Others6,
		Unknown)
	SELECT
		'SABA',
		1,
		SUM(r.Mj)+ SUM(r.M1)+ SUM(r.M2)+SUM(r.M3)+ SUM(r.M4)+ SUM(r.Others)+ SUM(r.Others1)+SUM(r.Others2)+SUM(r.Others3)+SUM(r.Others4)+SUM(r.Others5)+SUM(r.Others6)+SUM(r.Unknown),
		SUM(r.Mj),
		SUM(r.M1),
		SUM(r.M2),
		SUM(r.M3),
		SUM(r.M4),
		SUM(r.Others),
		SUM(r.Others1),
		SUM(r.Others2),
		SUM(r.Others3),
		SUM(r.Others4),
		SUM(r.Others5),
		SUM(r.Others6),
		SUM(r.Unknown)
	FROM @result AS r
	WHERE r.IsSaba=1
	
	--Insert bettype rest--
	INSERT INTO @result(
		[BetType],
		[IsSaba])
	SELECT r.BetType,
		r.IsSaba
	FROM @bettype AS r 
		LEFT JOIN @result AS mc
	ON mc.BetType=r.BetType
	WHERE mc.BetType IS NULL  
	
	UPDATE r
	SET r.[No]= b.[No],
		r.[Order]=b.[Order]
	FROM @result AS r
		INNER JOIN @bettype AS b
	ON r.BetType=b.BetType
	
	SELECT r.[No], 
		r.BetType,
		CASE WHEN r.Total = 0 THEN NULL ELSE r.Total END AS Total,
		CASE WHEN r.Mj = 0 THEN NULL ELSE r.Mj END AS Mj,
		CASE WHEN r.M1= 0 THEN NULL ELSE r.M1 END AS M1,
		CASE WHEN r.M2= 0 THEN NULL ELSE r.M2 END AS M2,
		CASE WHEN r.M3= 0 THEN NULL ELSE r.M3 END AS M3,
		CASE WHEN r.M4= 0 THEN NULL ELSE r.M4 END AS M4,
		CASE WHEN r.Others= 0 THEN NULL ELSE r.Others END AS Others,
		CASE WHEN r.Others1= 0 THEN NULL ELSE r.Others1 END AS Others1,
		CASE WHEN r.Others2= 0 THEN NULL ELSE r.Others2 END AS Others2,
		CASE WHEN r.Others3= 0 THEN NULL ELSE r.Others3 END AS Others3,
		CASE WHEN r.Others4= 0 THEN NULL ELSE r.Others4 END AS Others4,
		CASE WHEN r.Others5= 0 THEN NULL ELSE r.Others5 END AS Others5,
		CASE WHEN r.Others6= 0 THEN NULL ELSE r.Others6 END AS Others6,
		CASE WHEN r.Unknown= 0 THEN NULL ELSE r.Unknown END AS Unknown,
		r.IsSaba
	FROM @result AS r
	ORDER BY r.[Order] ASC
GO