
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20220701@Carlos
Task : Get OS league category option
DB: bodb_OWP

Revisions:
	20220701@Carlos: Initial - [Redmine: #174431]	
*/
USE [bodb_OWP]
GO

/****** Object:  Table [dbo].[OSMaxBet]    Script Date: 7/15/2022 3:36:20 PM ******/

CREATE TABLE OSLeagueSetting(
	LeagueSettingId INT IDENTITY(1,1) PRIMARY KEY,
	OSLeagueId INT NOT NULL,
	WeekMatchId INT,
	BetDelayId INT,
	KOFromTime TIME,
	KOToTime TIME,
	Remark VARCHAR(2000),
	IsManualUpdateScore BIT,
	IsIptvOnly BIT,
	MaxbetHDP MONEY,
	MaxbetOU MONEY,
	SpreadHDP MONEY,
	SpreadOU MONEY
)

ALTER TABLE OSLeague
   ADD  IsActive BIT NOT NULL DEFAULT(0),
    	RegionId INT,
        CategoryId INT
    
CREATE INDEX idx_league_id
ON OSLeagueSetting (LeagueSettingId);

CREATE TABLE OSRegionOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSCategoryOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSRoundOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSWeekMatchOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSStatusOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSOfferLineOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSBetDelayOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSProviderOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSBettypeOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	Label VARCHAR(100)
)

CREATE TABLE OSSettingRound(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	RoundId INT
)

CREATE INDEX idx_league_id
ON OSSettingRound (LeagueSettingId);

CREATE TABLE OSSettingOfferLine(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	OfferLineId INT
)

CREATE INDEX idx_league_id
ON OSSettingOfferLine (LeagueSettingId);

CREATE TABLE OSSettingProvider(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	ProviderId INT
)

CREATE INDEX idx_league_id
ON OSSettingProvider (LeagueSettingId);


CREATE TABLE OSSettingBettype(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	BettypeId INT
)

CREATE INDEX idx_league_id
ON OSSettingBettype (LeagueSettingId);

INSERT INTO OSBettypeOption(Label)
VALUES ('MNL'),
('HDP'),
('OU'),
('OE'),
('1H MNL'),
('1H HDP'),
('1H OU'),
('1H OE'),
('1&3 MNL'),
('1&3 HDP'),
('1&3 OU'),
('1&3 OE'),
('2&4 MNL'),
('2&4 HDP'),
('2&4 OU'),
('2&4 OE')

INSERT INTO OSStatusOption(Label)
VALUES ('Active'),
('Inactive')

INSERT INTO OSRoundOption(Label)
VALUES ('Pre Season'),
('Regular Season'),
('Consolation'),
('PlayOffs'),
('Semifinal'),
('Final'),
('All Star Game'),
('Classification'),
('Qualification'),
('Group Phase'),
('Quater Final'),
('1st Round'),
('2nd Round'),
('3rd Place')

INSERT INTO OSCategoryOption(Label)
VALUES ('Major'),
('Minor 1'),
('Minor 2'),
('Minor 3'),
('Minor 4'),
('Minor 5'),
('Minor 6')

INSERT INTO OSRegionOption(Label)
VALUES
('3x3 Asia'),
('3x3 Challenger'),
('3x3 Europe'),
('3x3 World'),
('America'),
('Africa'),
('Asia'),
('Europe'),
('USA'),
('Others')

INSERT INTO OSWeekMatchOption(Label)
VALUES
('2nd'),
('3rd'),
('4th'),
('5th'),
('6th'),
('7th'),
('8th'),
('9th'),
('10th'),
('11th'),
('12th'),
('13th'),
('14th'),
('15th'),
('16th'),
('17th'),
('18th'),
('19th'),
('20th'),
('21th'),
('22th'),
('23th'),
('24th'),
('25th'),
('26th'),
('27th'),
('28th')

INSERT INTO OSOfferLineOption(Label)
VALUES
('Offer 1 Line'),
('Offer 2 Lines'),
('Offer 3 Lines'),
('Offer 6 Lines'),
('HDP: Offer 2 Lines'),
('HDP: Offer 3 Lines'),
('HDP: Offer 6 Lines'),
('OU: Offer 2 Lines'),
('OU: Offer 3 Lines'),
('OU: Offer 6 Lines')

INSERT INTO OSBetDelayOption(Label)
VALUES
('Bet Delay 4s'),
('Bet Delay 6s'),
('Bet Delay 10s'),
('Bet Delay 12s'),
('Bet Delay 15s')

INSERT INTO OSProviderOption(Label)
VALUES
('CMT'),
('Venue Feed'),
('TV Feed')



---------------------------------------------------------------------------------------------
--> INIT DATA


CREATE TABLE OsLeagueTemp
(OsLeagueSettingId     INT, 
 OsleagueName   NVARCHAR(200), 
 IsActive       BIT, 
 Regions        INT, 
 Category       INT, 
 WeekMatchId    INT, 
 BetDelay       INT, 
 KOFrom         TIME, 
 KOTo           TIME, 
 Remark         NVARCHAR(2000), 
 ManualUpdScore BIT, 
 IPTVOnly       BIT, 
 SpreadHDP      MONEY, 
 SpreadOU       MONEY, 
 MaxbetHDP      MONEY, 
 MaxbetOU       MONEY, 
 FirstRound      BIT,
 SecoundRound BIT, 
 AllStarGame BIT, 
 Consolation BIT,
 Final BIt , 
 GroupPhase BIT, 
 PlayOff BIT, 
 PreSeason BIT, 
 Qualification BIT,
 [Classification] BIT,
 QuaterFinal BIT, 
 Semifinal BIT,
 RegularSeason BIT,
 ThridPlace BIT,
 Offer1lines    BIT, 
 Offer2lines    BIT, 
 Offer3lines    BIT, 
 Offer6lines    BIT, 
 HDP3Line       BIT, 
 OU6Line        BIT, 
 ProviderCMT    BIT, 
 ProviderTV     BIT, 
 ProviderVenue  BIT, 
 TypeMNL        BIT, 
 TypeHDP        BIT, 
 TypeOU         BIT, 
 TypeOE         BIT, 
 Type1HMNL      BIT, 
 Type1HHDP       BIT, 
 Type1HOU       BIT, 
 Type1HOE       BIT, 
 Type13MNL       BIT, 
 Type13HDP      BIT, 
 Type13OU       BIT, 
 Type13OE       BIT, 
 Type24MNL       BIT, 
 Type24HDP      BIT, 
 Type24OU       BIT, 
 Type24OE       BIT
);

INSERT INTO OsLeagueTemp values (1,'*NBA G League (in Orlando, Florida)',1,9,3,null,2,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(2,'*NBA G League (in Orlando, Florida)',1,9,3,null,2,null,null,'',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(3,'ABA League First Division',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(4,'ABA League Second Division',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(5,'ABA Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(6,'ABL Pre Sea Games Challenge 2022 (in Indonesia)',1,7,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(7,'Adriatic League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(8,'Africa League (in Rwanda)',1,5,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(9,'Africa League Qualifiers',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(10,'Agong Cup Men (in MABA Stadium, KL)',1,7,5,null,null,null,'16:00','',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(11,'Agong Cup Men (in MABA Stadium, KL)',1,7,5,null,null,'16:00',null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(12,'Albania Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(13,'Albania Superliga',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(14,'Algeria - Super Division',1,6,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(15,'Algeria Cup',1,6,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(16,'Algeria Cup Women',1,6,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(17,'Algeria Division Nationale 1 Women',1,6,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(18,'Alpe Adria Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(19,'Arab Nations Basketball Championship (in United Arab Emirates)',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(20,'Argentina ABB Primera',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(21,'Argentina La Liga',1,5,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(22,'Argentina La Liga Federal',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(23,'Argentina La Liga Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(24,'Argentina Liga de Desarrollo',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(25,'Argentina Liga Provincial de Mayores',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(26,'Argentina LNB',1,5,2,null,5,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(27,'Argentina Nivel 1 de Mendoza',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(28,'Argentina Primera de Mendoza Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(29,'Argentina Super 20',1,5,3,null,3,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(30,'Argentina Super 8',1,5,3,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(31,'Argentina Super Copa',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(32,'Argentina Superliga de Mendoza',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(33,'Argentina TFB',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(34,'ASEAN Basketball League',1,7,3,null,2,null,null,'',0,0,null,null,5000,4000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(35,'ASEAN Basketball League',1,7,3,null,2,null,null,'',0,0,null,null,1200,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(36,'ASEAN Basketball League',1,7,3,null,2,null,null,'',0,0,null,null,3800,3000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(37,'ASEAN Basketball League',1,7,3,null,2,null,null,'IMG',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(38,'Atlas International Invitational Tournament (in China)',1,7,3,null,null,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(39,'Australia Big V Championship Men',1,7,5,null,3,null,null,'',0,0,null,null,1200,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(40,'Australia Big V Championship Women',1,7,5,null,3,null,null,'',0,0,null,null,1200,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(41,'Australia NBL',1,7,2,null,2,null,null,'',0,0,null,null,12000,9000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(42,'Australia NBL',1,7,2,null,2,null,null,'',0,0,null,null,3000,2300,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(43,'Australia NBL',1,7,2,null,2,null,null,'',0,0,null,null,10000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(44,'Australia NBL Preseason',1,7,3,null,2,null,null,'',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(45,'Australia NBL1',1,7,4,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(46,'Australia NBL1 Women',1,7,4,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(47,'Australia QSL Division 1 Men',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(48,'Australia QSL Division 1 Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(49,'Australia Waratah League Men',1,7,5,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(50,'Australia Waratah League Women',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(51,'Australia WCC Men',1,7,4,null,3,null,null,'(Deposit Site Only)(Not Offer All MNL Market)',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(52,'Australia WCC Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(53,'Australia WNBL',1,7,3,null,3,null,null,'',0,0,null,null,5000,5000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(54,'Austria 2 Liga',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(55,'Austria Basketball Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(56,'Austria BDSL',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(57,'Austria BDSL Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(58,'Austria BSL',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(59,'Austria Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(60,'Austria Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(61,'Bahrain Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(62,'Bahrain Premier League',1,8,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(63,'Bahrain Super Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(64,'Balkan International Basketball League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(65,'Balkan League ',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(66,'Baltic League',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(67,'Baltic Women Basketball League',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(68,'Barbados Premier League',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(69,'Basketball Poland Basketball Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(70,'Basketball SEA Games 2021 (in Vietnam) - Basketball Men/Women',1,10,6,null,3,null,null,'(Below 15p [8000] [5000])(Above 15p [3000] [2000])',0,0,null,null,8000,5000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(71,'Belarus Premier League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(72,'Belarus Premier League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(73,'Belgium Basketball Championship Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(74,'Belgium Basketball Cup',1,8,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(75,'Belgium Basketball League',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(76,'Belgium Cup',1,8,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(77,'Belgium Euromillions',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(78,'Belgium PBL',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(79,'Belgium Pro League',1,8,5,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(80,'Belgium Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(81,'Belgium Top Division 1',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(82,'Belgium Top Division Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(83,'Belgrade 2019 (13-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(84,'BNXT League',1,8,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(85,'Bolivia Libobasquet',1,6,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(86,'Bolivia LNB',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(87,'Bosnia-Herzegovina Championship',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(88,'Bosnia-Herzegovina Championship Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(89,'Brazil Campeonato Brasileiro de Basquete',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(90,'Brazil Campeonato Carioca',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(91,'Brazil Campeonato Carioca U22',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(92,'Brazil Campeonato Carioca U23',1,5,5,null,5,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(93,'Brazil Campeonato Catarinense de Basquete',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(94,'Brazil Campeonato Catarinense de Basquete U22',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(95,'Brazil Campeonato Catarinense de Basquete Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(96,'Brazil Campeonato Estadual Amador',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(97,'Brazil Campeonato Estadual Da Divisao Especial',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(98,'Brazil Campeonato Goiano de Basquete',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(99,'Brazil Campeonato Interclubes U19',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(100,'Brazil Campeonato Paranaense',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(101,'Brazil Campeonato Paranaense Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(102,'Brazil Campeonato Paulista',1,5,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(103,'Brazil Campeonato Paulista Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(104,'Brazil Capixaba Basketball League',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(105,'Brazil Carioca Basketball Championship',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(106,'Brazil Copa Santa Catarina',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(107,'Brazil Copa Sao Paulo',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(108,'Brazil Copa Sao Paulo Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(109,'Brazil Copa Super 8',1,5,3,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(110,'Brazil FPB',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(111,'Brazil LBF Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(112,'Brazil LDB U22',1,5,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(113,'Brazil LSB Copa Baixada',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(114,'Brazil NBB',1,5,2,null,3,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(115,'Brazil Paulista A1 Division',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(116,'Brazil Paulista League Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(117,'Brazil U23 Brazilian Interclubs Championship Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(118,'British Basketball League',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(119,'British Basketball League Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(120,'British BBL Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(121,'British BBL Trophy',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(122,'British NBL Division 1',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(123,'British WBBL Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(124,'British WBBL Trophy Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(125,'Bulgaria Basketball League U19',1,8,5,null,5,null,null,'',0,0,40,40,500,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(126,'Bulgaria Championship Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(127,'Bulgaria Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(128,'Bulgaria NBL',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(129,'Cameroon National Championship',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(130,'Cameroon National Championship Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(131,'Champions League',1,8,3,null,3,null,null,'',0,0,null,null,3000,2300,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(132,'Champions League Americas',1,5,2,null,3,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(133,'Champions League Qualification',1,8,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(134,'Chile Liga de Desarrollo',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(135,'Chile Liga Saesa',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(136,'Chile LNB',1,5,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(137,'Chile LNB Cup',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(138,'Chile LNB Segunda Division',1,5,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(139,'China Basketball Development League',1,7,4,null,null,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(140,'China CBA',1,7,2,null,2,null,null,'',0,0,null,null,10000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(141,'China CBA (in Zhejiang)',1,7,2,null,2,null,null,'',0,0,null,null,10000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(142,'China CBA (New)',1,7,2,null,2,null,null,'',0,0,null,null,10000,10000,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(143,'China CBA All Star Game',1,7,null,null,2,null,null,'Minor 1',0,0,null,null,3000,1500,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(144,'China CBA All Star Game',1,7,null,null,null,null,null,'Minor 4',0,0,null,null,1500,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(145,'China CBA Final',1,7,2,null,2,null,null,'',0,0,null,null,10000,10000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(146,'China CBA Preseason',1,7,2,null,2,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(147,'China CBA Preseason',1,7,2,null,2,null,null,'',0,0,null,null,4000,3000,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,1,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(148,'China CBA Preseason (in Zhejiang)',1,7,3,null,2,null,null,'(Not Offer All MNL Market)',0,0,null,null,2000,1600,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(149,'China CBA Summer League',1,7,5,null,null,null,null,'',0,0,null,null,1000,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(150,'China CBDL (in Haidong)',1,7,4,null,3,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(151,'China CBDL (in Jiangchuan)',1,7,4,null,3,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(152,'China CBDL (in Shaoyang)',1,7,4,null,3,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(153,'China CBDL (in Yinchuan)',1,7,4,null,3,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(154,'China CUBA League 1',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(155,'China CUBA League 1 Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(156,'China Golden Dragon Cup',1,10,5,null,5,null,null,'',0,0,null,null,350,350,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(157,'China National Games Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(158,'China NBL',1,7,3,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(159,'China NBL',1,7,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(160,'China NBL',1,7,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(161,'China NBL',1,7,3,null,3,null,null,'',0,0,null,null,1200,1000,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(162,'China NBL (in Hubei)',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(163,'China NBL (in Jiangsu)',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(164,'China NBL (in Shaanxi)',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(165,'China NBL U19 (in Guizhou)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(166,'China NBL U21',1,7,4,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(167,'China U19 National Games Qualifiers',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(168,'China U22 National Games Qualifiers',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(169,'China WCBA',1,7,3,null,3,null,null,'',0,0,null,null,2000,1300,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(170,'China WCBA',1,7,3,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(171,'China WCBA',1,7,3,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(172,'China WCBA',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(173,'China WCBA',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1300,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(174,'China WCBA (in Anhui)',1,7,5,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(175,'China WCBA (in Inner Mongolia)',1,7,5,null,3,null,null,'(Not Offer All MNL Market)',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(176,'China WCBA (in Sichuan)',1,7,5,null,3,null,null,'(Not Offer All MNL Market)',0,0,30,40,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(177,'China WCBA All Star Game',1,7,3,null,3,null,null,'',0,0,null,null,3000,1500,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(178,'China WNBL',1,7,3,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(179,'China WNBL',1,7,3,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(180,'China WNBL',1,7,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(181,'China WNBL',1,7,3,null,3,null,null,'',0,0,null,null,1200,800,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(182,'Chinese Taipei Hualien Invitational',1,7,2,null,3,null,null,'',0,0,null,null,1000,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(183,'Chinese Taipei SBL Summer Challenge',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(184,'Club Friendly',1,10,5,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(185,'Club Friendly Women',1,10,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(186,'Colombia Liga Superior Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(187,'Colombia Professional League',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(188,'Costa Rica Liga Superior de Baloncesto',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(189,'Croatia A2 League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(190,'Croatia Cup Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(191,'Croatia Druge Lige',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(192,'Croatia First League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(193,'Croatia Kresimir Cosic Cup',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(194,'Croatia Premier League',1,8,4,null,5,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(195,'Croatia Premier League Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(196,'Cuba Liga Superior de Baloncesto',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(197,'Cuba Liga Superior de Baloncesto Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(198,'Czech Republic 1.Liga',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(199,'Czech Republic 1.Liga Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(200,'Czech Republic Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(201,'Czech Republic Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(202,'Czech Republic NBL',1,8,4,null,5,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(203,'Czech Republic ZBL',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(204,'Czech Republic ZBL Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(205,'Debrecen 2019 (27-AUG-2019)',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(206,'Denmark Basketligaen',1,8,4,null,5,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(207,'Denmark Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(208,'Denmark Dameligaen Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(209,'Denmark Women Basketball League',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(210,'Dominican Republic Baloncesto Superior',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(211,'Dominican Republic LNB',1,8,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(212,'Dominican Republic Superior de Santiago',1,8,4,null,5,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(213,'Dominican Republic TBS del Distrito Nacional',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(214,'Dutch Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(215,'Ecuador Liga de Desarrollo Men U24',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(216,'Edmonton 2019 (28-SEP-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(217,'El Salvador FESABAL U23',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(218,'El Salvador LFB Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(219,'El Salvador LMB',1,5,4,null,5,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(220,'El Salvador LMB Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(221,'Estonia 1 Liiga',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(222,'Estonia Championship Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(223,'Estonia Cup Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(224,'Estonia KML',1,8,7,null,5,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(225,'Estonia Premier League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(226,'Estonia Super Cup',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(227,'Eurocup Men',1,8,3,null,3,null,null,'',0,0,null,null,1800,1400,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(228,'Eurocup Women',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(229,'Eurocup Women Qualification',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(230,'EuroLeague Basketball Next Generation Tournament+M263D263:J263',1,8,7,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(231,'Euroleague Men',1,8,3,null,3,null,null,'',0,0,null,null,6000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(232,'Euroleague Women',1,8,3,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(233,'Euroleague Women Qualification',1,8,3,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(234,'European North Basketball League',1,10,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(235,'European Women Basketball League',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(236,'F.I.P. Rimini 2019 (19-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(237,'FIBA 3x3 Europe Cup Qualifier (in Israel & Romania)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(238,'FIBA 3x3 Europe Cup Qualifier Women (in Israel & Romania)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(239,'FIBA 3x3 Europe Cup Qualifiers',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(240,'FIBA 3x3 Meitian Cup',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(241,'FIBA 3x3 Nations League (in Israel)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(242,'FIBA 3x3 Nations League Women (in Israel)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(243,'FIBA 3x3 Novi Sad Challenger',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(244,'FIBA 3x3 Series Women (in Poitiers, France)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(245,'FIBA 3x3 Series Women (in Ulaanbaatar, Mongolia)',1,2,4,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(246,'FIBA 3x3 U23 Nations League (in France)',1,3,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(247,'FIBA 3x3 U23 Nations League (in Israel)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(248,'FIBA 3x3 U23 Nations League Women (in France)',1,3,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(249,'FIBA 3x3 U23 Nations League Women (in Hungary)',1,3,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(250,'FIBA 3x3 U23 Nations League Women (in Israel)',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(251,'FIBA 3x3 Ulaanbaatar Challenger',1,2,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(252,'FIBA 3x3 World Cup Men (in Belgium)',1,4,3,null,1,null,null,'',0,0,null,null,2000,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(253,'FIBA 3x3 World Cup Women (in Belgium)',1,4,3,null,1,null,null,'',0,0,null,null,2000,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(254,'FIBA 3x3 World Tour Doha Masters',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(255,'FIBA 3x3 World Tour Jeddah Final',1,4,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(256,'FIBA 3x3 World Tour Manila Masters',1,2,4,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(257,'FIBA Africa League Qualifying (in Kigali)',1,10,3,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(258,'FIBA Africa Women Champions Cup (in Egypt)',1,10,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(259,'FIBA AfroBasket 2021 (in Rwanda)',1,10,3,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(260,'FIBA AfroBasket 2021 Qualifiers (in Rwanda & Egypt)',1,10,4,null,3,null,null,'',0,0,null,null,1000,700,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(261,'FIBA AfroBasket 2021 Qualifiers (in Tunisia & Cameroon)',1,10,4,null,3,null,null,'',0,0,null,null,1000,700,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(262,'FIBA AfroBasket 2021 Qualifiers (NEW)',1,10,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(263,'FIBA AfroBasket 2021 Qualifiers Women',1,10,5,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(264,'FIBA Americas League',1,10,2,null,3,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(265,'FIBA AmeriCup 2022 Qualifiers',1,10,3,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(266,'FIBA AmeriCup Women (in Puerto Rico)',1,10,3,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(267,'FIBA Asia Champions Cup (in Thailand)',1,10,2,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(268,'FIBA Asia Cup 2021 Eastern Region Pre-Qualifier (in Thailand)',1,10,3,null,2,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(269,'FIBA Asia Cup 2021 Qualifier',1,10,2,null,2,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(270,'FIBA Asia Cup 2021 Qualifiers',1,10,2,null,3,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(271,'FIBA Asia Cup 2025 Pre-Qualifiers',1,10,2,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(272,'FIBA Centrobasket Championship Women (in El Salvador)',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(273,'FIBA EuroBasket 2022 Qualifiers',1,10,2,null,2,null,null,'(Below 15 points)',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(274,'FIBA EuroBasket 2022 Qualifiers',1,10,2,null,2,null,null,'(Above 15 points)',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(275,'FIBA Eurobasket 2025 Pre-Qualifiers',1,10,3,null,3,null,null,'(Below 15p [3000] [3000])(Above 15p [2000] [1500])',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(276,'FIBA Eurobasket Men 2021 Pre-Qualifiers',1,10,2,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [2000] [1500])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(277,'FIBA Eurobasket Women 2019 ',1,10,2,null,3,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(278,'FIBA Eurobasket Women 2019 ',1,10,2,null,3,null,null,'',0,0,null,null,4000,3000,null,null,null,null,null,null,null,null,null,1,1,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(279,'FIBA Eurobasket Women 2019 ',1,10,2,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(280,'FIBA Eurobasket Women 2019 ',1,10,2,null,3,null,null,'',0,0,null,null,5000,4000,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(281,'FIBA Eurobasket Women 2021 (in Spain & France)',1,10,3,null,3,null,null,'(Above 15 points)',0,0,null,null,10000,10000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(282,'FIBA Eurobasket Women 2021 Qualification',1,10,3,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(283,'FIBA Europe Cup',1,8,3,null,3,null,null,'',0,0,null,null,1600,1200,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(284,'FIBA Europe Cup',1,8,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(285,'FIBA Europe Cup Qualifiers',1,8,2,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(286,'FIBA Europe SuperCup Women',1,8,2,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(287,'FIBA European Championship Small Countries Men (in Ireland)',1,10,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(288,'FIBA European Championship Small Countries Men (in Malta)',1,10,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(289,'FIBA European Championship Small Countries Women (in Cyprus)',1,10,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(290,'FIBA Intercontinental Cup',1,8,3,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [1500] [1000])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(291,'FIBA Liga Sudamericana',1,10,2,null,3,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(292,'FIBA Liga Sudamericana Women',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(293,'FIBA Micronesian Cup (in Guam)',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(294,'FIBA Micronesian Cup Women (in Guam)',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(295,'FIBA Olympic Qualifying Tournament',1,10,2,null,2,null,null,'',0,0,null,null,10000,10000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(296,'FIBA South American Championship Women ',1,10,3,null,3,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(297,'FIBA South American League for Mens Clubs',1,10,3,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(298,'FIBA U16 African Championship (in Egypt)',1,10,Null,null,3,null,null,'Minor 6',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(299,'FIBA U16 African Championship (in Egypt)',1,10,Null,null,4,null,null,'Minor 2',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(300,'FIBA U16 African Championship Women (in Egypt)',1,10,null,null,3,null,null,'Minor 6',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(301,'FIBA U16 African Championship Women (in Egypt)',1,10,null,null,5,null,null,'Minor 4',0,0,null,null,500,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(302,'FIBA U16 Americas Championship (in Mexico)',1,10,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(303,'FIBA U16 Americas Championship 2021 (in Mexico)',1,10,7,null,3,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(304,'FIBA U16 Americas Championship Women (in Mexico)',1,10,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(305,'FIBA U16 Americas Women Championship 2021 (in Mexico)',1,10,7,null,3,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(306,'FIBA U16 Asian Championship (in Qatar)',1,10,7,null,5,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(307,'FIBA U16 Asian Championship Women (in Jordan)',1,10,7,null,5,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(308,'FIBA U16 European Challengers Men',1,10,Null,null,3,null,null,'Minor 6',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(309,'FIBA U16 European Challengers Men',1,10,Null,null,5,null,null,'Minor 4',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(310,'FIBA U16 European Challengers Women',1,10,null,null,3,null,null,'Minor 6',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(311,'FIBA U16 European Challengers Women',1,10,null,null,5,null,null,'Minor 4',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(312,'FIBA U16 European Championship Men ( in Italy)',1,10,7,null,3,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(313,'FIBA U16 European Championship Men ( in Montenegro)',1,10,7,null,3,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(314,'FIBA U17 Basketball World Cup (in Spain)',1,10,3,null,3,null,null,'(Below 15p [2000] [2000])(Above 15p [1000] [1000])',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(315,'FIBA U17 World Cup',1,10,3,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [2000] [1500])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(316,'FIBA U18 Americas Championship (in Mexico)',1,10,7,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(317,'FIBA U18 Americas Championship Women (in Argentina)',1,10,7,null,5,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(318,'FIBA U18 European Challengers',1,10,3,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(319,'FIBA U18 European Challengers Women',1,10,3,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(320,'FIBA U18 South American Championship Women (in Argentina)',1,10,7,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(321,'FIBA U18 Womens Asian Championship',1,10,4,null,3,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(322,'FIBA U18 Womens Asian Championship',1,10,4,null,3,null,null,'',0,0,null,null,3000,2000,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(323,'FIBA U19 Women World Cup 2021 (in Hungary)',1,10,3,null,3,null,null,'(Below 15 points)',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(324,'FIBA U19 World Cup',1,10,3,null,3,null,null,'(Below 15p [2000] [1500])(Above 15p [1500] [1200])',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(325,'FIBA U19 World Cup 2021 (in Latvia)',1,10,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(326,'FIBA U20 European Challengers',1,10,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(327,'FIBA U20 European Challengers Women',1,10,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(328,'FIBA U20 European Championship Men (in Germany & Bulgaria)',1,10,3,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [1500] [1000])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(329,'FIBA Women AfroBasket 2021 (in Cameroon)',1,10,3,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(330,'FIBA Women Asia Cup 2021 (in Jordan)',1,10,3,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(331,'FIBA Women World Cup 2022 Qualifiers (in Japan)',1,10,3,null,3,null,null,'',0,0,null,null,6000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(332,'FIBA Women World Cup 2022 Qualifiers (in Serbia)',1,10,3,null,3,null,null,'',0,0,null,null,6000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(333,'FIBA Women World Cup 2022 Qualifiers (in USA)',1,10,3,null,3,null,null,'',0,0,null,null,6000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(334,'FIBA World Cup 2019 (In China)',1,10,2,null,2,null,null,'(Below 15p [40000] [25000])(Above 15p [30000] [20000])',0,0,null,null,40000,25000,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(335,'FIBA World Cup 2019 (In China)',1,10,2,null,2,null,null,'(Below 15p [40000] [25000])(Above 15p [30000] [20000])',0,0,null,null,40000,25000,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(336,'FIBA World Cup 2019 (In China)',1,10,2,null,2,null,null,'(Below 15p [40000] [25000])(Above 15p [30000] [20000])',0,0,null,null,40000,25000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(337,'FIBA World Cup 2023 African Qualifiers',1,6,2,null,3,null,null,'(Below 15p [3000] [3000])(Above 15p [2000] [2000])',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(338,'FIBA World Cup 2023 Americas Qualifiers',1,5,2,null,3,null,null,'(Below 15p [3000] [3000])(Above 15p [2000] [2000])',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(339,'FIBA World Cup 2023 Asian Qualifiers',1,7,2,null,3,null,null,'(Below 15p [3000] [3000])(Above 15p [2000] [2000])',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(340,'FIBA World Cup 2023 European Qualifiers',1,8,2,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [2000] [1000])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(341,'FIBA World Cup 2023 Pre-Qualifiers (Africa)',1,6,3,null,2,null,null,'(Below 15p [2000] [1500]) (Above 15p [1000] [1000])',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(342,'FIBA World Cup 2023 Pre-Qualifiers (America)',1,5,3,null,2,null,null,'(Below 15p [3000] [2000]) (Above 15p [2000] [1000])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(343,'FIBA World Cup 2023 Pre-Qualifiers (Asia)',1,7,3,null,2,null,null,'(Below 15p [5000] [3000]) (Above 15p [2000] [1500])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(344,'FIBA World Cup 2023 Pre-Qualifiers (Europe)',1,8,2,null,2,null,null,'(Below 15p [3000] [2000]) (Above 15p [2000] [1000])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(345,'FIBA World Cup Qualification Africa',1,10,2,null,2,null,null,'(Below 15p [3000] [2000])(Above 15p [2000] [1500])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(346,'FIBA World Cup Qualification America',1,10,2,null,2,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(347,'FIBA World Cup Qualification Asia ',1,10,2,null,2,null,null,'(Below 15p [8000] [5000])(Above 15p [5000] [3000])',0,0,null,null,8000,5000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(348,'FIBA World Cup Qualification Europe',1,10,2,null,2,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(349,'FIBA World Cup Women 2018 (in Spain)',1,10,2,null,2,null,null,'(Below 15p [5000] [3000])(Above 15p [3000] [2000])',0,0,null,null,5000,3000,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(350,'FIBA World Cup Women 2018 (in Spain)',1,10,2,null,2,null,null,'',0,0,null,null,8000,5000,null,null,null,null,1,null,null,null,null,null,null,1,null,1,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(351,'Finland Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(352,'Finland Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(353,'Finland Division 1 Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(354,'Finland Division 1A',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(355,'Finland Division 1B',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(356,'Finland Korisliiga',1,8,2,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(357,'Finland Korisliiga Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(358,'France Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(359,'France Basketball League Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(360,'France Cup Women',1,8,4,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(361,'France Leaders Cup Pro B',1,8,3,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(362,'France LF2 Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(363,'France Match des Champions Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(364,'France Nationale 1',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(365,'France Pro A',1,8,3,null,3,null,null,'',0,0,null,null,2000,1600,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(366,'France Pro B',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(367,'France Women League 2',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(368,'Friendly Match',1,10,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(369,'Georgia A League',1,8,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(370,'Georgia Basketball Development League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(371,'Georgia Cup',1,8,5,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(372,'Georgia Dudu Dadiani Memorial',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(373,'Georgia Superleague',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(374,'Georgia University League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(375,'Germany 2. Basketball Bundesliga Pro A',1,8,3,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(376,'Germany 2. Basketball Bundesliga Pro B',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(377,'Germany Basketball Bundesliga',1,8,3,null,3,null,null,'',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(378,'Germany Basketball Bundesliga Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(379,'Germany Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(380,'Ghetto Basket Riga 2019 (07-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(381,'Gloria Cup Tournament II ',1,7,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(382,'Greece A1 Women',1,8,4,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(383,'Greece A2',1,8,5,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(384,'Greece Basketball Cup',1,8,3,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(385,'Greece Basketball Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(386,'Greece Basketball League',1,8,3,null,3,null,null,'',0,0,null,null,2300,1800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(387,'Greece Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(388,'Hong Kong Basketball League',1,7,5,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(389,'Hong Kong Basketball League Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(390,'Hong Kong Silver Shield Cup',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(391,'Hongxiang Holdings Haining Challenger (29-JUN-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(392,'Huaian 2019 (20-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(393,'Hungary Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(394,'Hungary Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(395,'Hungary NB 1',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(396,'Hungary NB 1 Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(397,'Iceland Basketball Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(398,'Iceland Premier League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(399,'Iceland Premier League Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(400,'Indonesia Basketball League',1,7,4,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(401,'Indonesia Srikandi Cup Women',1,7,3,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(402,'Inje 2019 (31-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(403,'International Friendly',1,10,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(404,'International Friendly U19',1,10,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(405,'International Friendly U20',1,10,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(406,'International Friendly Women',1,10,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(407,'International Friendly Women U20',1,10,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(408,'Iran Super League',1,7,4,null,5,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(409,'Iraqi Basketball league',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(410,'Ireland Super League',1,8,3,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(411,'Israel Basketball League Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(412,'Israel Basketball Super League',1,8,2,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(413,'Israel National Cup',1,8,4,null,3,null,null,'',0,0,null,null,750,600,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(414,'Israel National League',1,8,6,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(415,'Israel Premier League Women',1,8,6,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(416,'Israel State Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(417,'Italy Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(418,'Italy Basketball Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(419,'Italy Basketball Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(420,'Italy Basketball Super Cup Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(421,'Italy Cup A1 Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(422,'Italy Cup A2 Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(423,'Italy LBA Supercoppa',1,8,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(424,'Italy Lega Basket Serie A',1,8,3,null,3,null,null,'',0,0,null,null,2300,2300,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(425,'Italy Next Gen U19 Cup',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(426,'Italy Serie A1 Women',1,8,4,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(427,'Italy Serie A2',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(428,'Italy Serie A2 Cup',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(429,'Italy Serie A2 Supercup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(430,'Italy Serie A2 Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(431,'Italy Serie B',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(432,'Italy Serie B Supercoppa',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(433,'Italy Supercoppa LNP',1,8,5,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(434,'Italy Supercoppa Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(435,'Italy Suppercoppa ',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(436,'Japan 3x3 EXE Premier',1,1,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(437,'Japan B.League Early Cup',1,7,3,null,3,null,null,'',0,0,null,null,1200,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(438,'Japan B1.League',1,7,3,null,3,null,null,'',0,0,null,null,4000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(439,'Japan B2.League',1,7,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(440,'Japan B3.League',1,7,3,null,5,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(441,'Japan Basketball League Women',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,1,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(442,'Japan Basketball League Women',1,7,3,null,3,null,null,'(Not Offer All MNL Market)',0,0,30,40,1800,1400,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(443,'Japan Emperors Cup',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(444,'Japan Empress Cup',1,7,3,null,3,null,null,'',0,0,null,null,1800,1400,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(445,'Jeddah 2019 (18-OCT-2019)',1,4,3,null,1,null,null,'',0,0,null,null,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(446,'Jeju 2019 (05-OCT-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(447,'Jordan Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(448,'Jordan First Division',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(449,'Jordan King Cup',1,8,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(450,'Jordan Premier League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(451,'Juegos Bolivarianos 2022 (in Colombia) - Basketball Men U19',1,5,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(452,'Juegos Bolivarianos 2022 (in Colombia) - Basketball Women',1,5,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(453,'Kaohsiung City 2019 (21-SEP-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(454,'Kazakhstan National League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(455,'KBL Summer Match',1,7,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(456,'Korea KUSF Basketball U-League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(457,'Korea KUSF Basketball U-League Women',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(458,'Korea Summer League Cup Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(459,'Latvia LBL',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(460,'Latvia LBL Division 1',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(461,'Latvia NBL',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(462,'Latvia-Estonia Basketball League',1,8,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(463,'Lausanne 2019 (23-AUG-2019)',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(464,'Lebanon FLB League',1,8,4,null,5,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(465,'Lithuania Gealan SKL Summer ',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(466,'Lithuania Kaunas',1,8,6,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(467,'Lithuania King Mindaugas Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(468,'Lithuania League Division A Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(469,'Lithuania League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(470,'Lithuania LKL',1,8,3,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(471,'Lithuania NKL',1,8,5,null,5,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(472,'Ljubljana 2019 (17-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(473,'Los Angeles 2019 (20-SEP-2019)',1,4,3,null,1,null,null,'',0,0,null,null,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(474,'Luxembourg LBBL',1,8,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(475,'MABA Cup (in Kuala Lumpur)',1,7,4,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(476,'Malaysia MABA Cup (in Pulau Pinang)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(477,'Malaysia Pro League Men',1,7,5,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(478,'Malaysia Pro League Women',1,7,5,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(479,'Malta LBC',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(480,'Malta National Knockout Cup Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(481,'Malta National League',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(482,'Malta National League Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(483,'Mediterranean Games 2022 (in Algeria) - Basketball 3x3 Men U23',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(484,'Mediterranean Games 2022 (in Algeria) - Basketball 3x3 Women U23',1,4,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(485,'Mexico Cibacopa',1,5,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(486,'Mexico Cibacopa Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(487,'Mexico CIBAPAC',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(488,'Mexico LBP',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(489,'Mexico LMBPF Women',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(490,'Mexico LNBP',1,5,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(491,'Montreal 2019 (07-SEP-2019)',1,4,3,null,1,null,null,'',0,0,null,null,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(492,'Nanjing 2019 (12-OCT-2019)',1,4,3,null,1,null,null,'',0,0,null,null,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(493,'National Games of China 2021 (in Shaanxi)',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(494,'National Games of China 2021 (in Shaanxi) - Basketball U19 Men',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(495,'National Games of China 2021 (in Shaanxi) - Basketball U19 Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(496,'National Games of China 2021 (in Shaanxi) - Basketball U22 Men',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(497,'NBA',1,9,1,1,2,null,null,'',0,0,null,null,15000,10000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
(498,'NBA 2K League',1,10,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(499,'NBA G League',1,9,3,null,2,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(500,'NBA G League',1,9,3,null,2,null,null,'',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(501,'NBA Most 3 Points',1,null,null,null,null,null,null,'',0,0,24,null,700,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(502,'NBA Most Point Scored',1,null,null,null,null,null,null,'',0,0,null,30,null,700,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,null),
(503,'NBA Play-In Tournament',1,9,1,null,2,null,null,'',0,0,null,null,40000,30000,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
(504,'NBA Preseason (New)',1,9,1,null,2,null,null,'',0,0,null,null,10000,5000,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
(505,'NBA Regular Season (New)',1,9,1,null,2,null,null,'',0,0,null,null,40000,30000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,1,1,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
(506,'NBA Regular Season (New)(Last Two Match)',1,9,1,null,2,null,null,'',0,0,null,null,75000,30000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,1,1,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
(507,'NBA Scrimmage Games',1,9,2,null,3,null,null,'',0,0,null,null,1500,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(508,'NBA Summer League',1,9,2,null,2,null,null,'',0,0,null,null,8000,5000,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(509,'NBA Summer League',1,9,2,null,2,null,null,'',0,0,null,null,15000,10000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(510,'NBA Summer League',1,9,2,null,2,null,null,'',0,0,null,null,15000,10000,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(511,'NBA Summer League',1,9,2,null,2,null,null,'',0,0,null,null,8000,5000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(512,'NBA Summer League (in California)',1,9,2,null,2,null,null,'',0,0,null,null,8000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(513,'NBA Summer League (in Sacramento)',1,9,2,null,2,null,null,'',0,0,null,null,8000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(514,'NBA Summer League (in Utah)',1,9,2,null,2,null,null,'',0,0,null,null,8000,8000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(515,'NCAA Basketball Men',1,9,2,null,3,'11:00',null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, 1,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(516,'NCAA Basketball Men',1,9,2,null,3,'01:00','05:00','',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, 1,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(517,'NCAA Basketball Men',1,9,2,null,3,'05:00','11:00','',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, 1,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(518,'NCAA Basketball Men',1,9,2,null,3,null,null,'',0,0,null,null,8000,6000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, 1,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(519,'NCAA Basketball Men',1,9,2,null,5,'11:00',null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,1, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(520,'NCAA Basketball Men',1,9,2,null,5,'01:00','05:00','',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,1, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(521,'NCAA Basketball Men',1,9,2,null,5,'05:00','11:00','',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,1, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(522,'NCAA Basketball Men',1,9,2,null,5,null,null,'',0,0,null,null,8000,6000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,1, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(523,'NCAA Basketball Men - National Invitation Tournament',1,9,3,null,3,'11:00',null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(524,'NCAA Basketball Men - National Invitation Tournament',1,9,3,null,3,'01:00','05:00','',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(525,'NCAA Basketball Men - National Invitation Tournament',1,9,3,null,3,'05:00','11:00','',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(526,'NCAA Basketball Men Div 2',1,9,2,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(527,'NCAA Basketball Women',1,9,4,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,1, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(528,'NCAA Basketball Women',1,9,4,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, 1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(529,'NCAA The Basketball Classic',1,9,2,null,3,null,null,'',0,0,30,40,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(530,'NCAA tournament Final Four (TV Feed)',1,9,2,null,3,null,null,'',0,0,null,null,4000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(531,'NCAA tournament Final Four (Venue Feed)',1,9,2,null,3,null,null,'',0,0,null,null,6000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(532,'Netherlands Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(533,'Netherlands DBL',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(534,'New Zealand D-League Women (in Auckland)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(535,'New Zealand NBL',1,7,3,null,2,null,null,'',0,0,null,null,7500,4500,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(536,'New Zealand NBL',1,7,3,null,2,null,null,'',0,0,null,null,1800,1400,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(537,'New Zealand NBL',1,7,3,null,2,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(538,'New Zealand NBL Women (in Auckland)',1,7,4,null,2,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(539,'New Zealand Tauihi Basketball Aotearoa Women',1,7,4,null,2,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(540,'Nicaragua LSB',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(541,'Nicaragua LSBF Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(542,'Norway 1. Division',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(543,'Norway BLNO league',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(544,'Norway BLNO League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(545,'Norway Firi League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(546,'Norway Firi League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(547,'Nossa Liga de Basquete',1,5,6,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(548,'Olympics Tokyo 2020 - Basketball FIBA 3x3 Basketball',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(549,'Olympics Tokyo 2020 Men',1,10,2,null,3,null,null,'',0,0,null,null,40000,40000,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(550,'Olympics Tokyo 2020 Men',1,10,2,null,5,null,null,'',0,0,null,null,20000,20000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(551,'Olympics Tokyo 2020 Women',1,10,2,null,3,null,null,'',0,0,null,null,20000,20000,null,null,null,null,1,null,null,null,null,null,null,1,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(552,'Olympics Tokyo 2020 Women',1,10,2,null,5,null,null,'',0,0,null,null,10000,10000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(553,'Panama Basketball League U21',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(554,'Panama LPB',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(555,'Panama LPB U21',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(556,'Panama LPBF Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(557,'Paraguay Liga Nacional de Basquetbol',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(558,'Paraguay Liga Nacional Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(559,'PBA Governors Cup',1,7,2,null,3,null,null,'',0,0,null,null,4000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(560,'PBA Philippine Cup',1,7,2,null,3,null,null,'',0,0,null,null,6000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(561,'Peru Liga de Lima',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(562,'Philippine MPBL',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(563,'Philippine NBL Chairmans Cup',1,7,5,null,3,null,null,'(Dirty)',0,0,null,null,500,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(564,'Philippine WNBL',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(565,'Philippines Maharlika Basketball League',1,7,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(566,'Philippines PBA Commissioner''s Cup',1,7,2,null,3,null,null,'',0,0,null,null,7500,6000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(567,'Philippines VisMin Super Cup',1,7,5,null,3,null,null,'',0,0,40,40,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(568,'Poitiers 2019 (05-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(569,'Poland 1 Liga',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(570,'Poland 1 Liga Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(571,'Poland 2 Liga',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(572,'Poland 2 Liga Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(573,'Poland 3 Liga',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(574,'Poland Basketball Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(575,'Poland Basketball League',1,8,2,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(576,'Poland Basketball League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(577,'Poland Basketball Super Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(578,'Poland Basketball Super Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(579,'Poland Super Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(580,'Portugal Basketball Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(581,'Portugal Campeonato Nacional 1 Division',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(582,'Portugal Cup',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(583,'Portugal Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(584,'Portugal Division 1 Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(585,'Portugal Hugo dos Santos Cup',1,5,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(586,'Portugal LFB Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(587,'Portugal LPB',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(588,'Portugal Nacional 1A Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(589,'Portugal Nacional 2A',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(590,'Portugal Nacional Senior Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(591,'Portugal Super Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(592,'Prague 2019 (03-AUG-2019)',1,4,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(593,'Puerto Rican Baloncesto Superior Nacional',1,5,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(594,'Puerto Rico Baloncesto Superior Nacional',1,5,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(595,'Puerto Rico Baloncesto Superior Nacional Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(596,'Qatar Basketball League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(597,'Qatar Cup',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(598,'Qatar Emir Cup',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(599,'Raiffeisen Bank Bucharest 2019 (10-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(600,'Raudondvaris Challenger 2019 (03-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(601,'Romania Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(602,'Romania Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(603,'Romania Liga 1',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(604,'Romania LNB',1,8,2,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(605,'Romania LNB Women',1,8,5,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(606,'Romania National Championship U20',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(607,'Russia 3x3 Liga Pro ',1,4,4,null,1,null,null,'',0,0,null,null,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(608,'Russia Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(609,'Russia Basketball Cup Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(610,'Russia Basketball Super League 1',1,8,5,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(611,'Russia Basketball Super League 1 Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(612,'Russia Basketball Super League 2',1,8,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(613,'Russia Basketball Super League 2 Women',1,8,5,null,5,null,null,'(Deposit Site Only)',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(614,'Russia MLBL',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(615,'Russia MLBL Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(616,'Russia Nevskaya Division 1',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(617,'Russia Nevskaya Division 2',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(618,'Russia Nevskaya Division 3',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(619,'Russia Nevskaya Division 4',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(620,'Russia Nevskaya Division 5',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(621,'Russia Nevskaya Division 6',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(622,'Russia Premier League Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(623,'Rwanda National Basketball League',1,8,5,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(624,'SABA NBA 2K20 Classic Virtual',1,10,4,null,null,null,null,'',1,0,null,null,500,400,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(625,'SABA NBA 2K20 Friendly Virtual',1,10,4,null,null,null,null,'',1,0,null,null,500,400,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(626,'Saigon Premier Basketball League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(627,'Saskatoon Masters 2019 (20-JUL-2019)',1,4,3,null,1,null,null,'',0,0,null,null,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(628,'Saudi Arabia Golden Square Championship',1,7,5,null,5,null,null,'',0,0,24,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(629,'Saudi Arabia Premier League',1,7,5,null,3,null,null,'',0,0,24,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(630,'SEA Games 2021 (in Vietnam) - Basketball FIBA 3x3 Basketball Men/Women',1,4,3,null,1,null,null,'',0,0,null,null,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(631,'Senegal Basketball Division 1 Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(632,'Senegal Cup',1,6,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(633,'Senegal Cup Women',1,6,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(634,'Senegal National 1',1,6,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(635,'Senegal National 1 Women',1,6,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(636,'Seoul 2019 (28-SEP-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(637,'Serbia Basketball Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(638,'Serbia Basketball League Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(639,'Serbia KLS',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(640,'Serbia KLS Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(641,'Serbia Second League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(642,'Serbia Superliga',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(643,'Serbia Superliga Women',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(644,'Seri Mutiara Cup (in Malaysia)',1,7,5,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(645,'Sino-European Champions Cup',1,7,3,null,null,null,null,'(Below 15p [8000] [6000])(Above 15p [4000] [2000])',0,0,null,null,8000,6000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(646,'Sino-European Champions Cup (in China)',1,7,4,null,null,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(647,'Slovakia Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(648,'Slovakia Federal Cup',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(649,'Slovakia SBL',1,8,4,null,5,null,null,'(Not Offer Quarters)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(650,'Slovakia SBL Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(651,'Slovenia 1. SKL Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(652,'Slovenia 2. SKL',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(653,'Slovenia Basketball Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(654,'Slovenia Basketball League',1,8,4,null,3,null,null,'(Not Offer Quarters)',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(655,'Slovenia SKL',1,8,4,null,3,null,null,'(Not Offer Quarters)',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(656,'Slovenia Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(657,'South Africa National League',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(658,'South Asian Basketball Championship (in Bangladesh)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(659,'South Korea KBL (New)',1,7,3,null,2,null,null,'',0,0,null,null,5000,5000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(660,'South Korea KBL All Star Game',1,7,2,null,2,null,null,'',0,0,null,null,2000,1000,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(661,'South Korea KBL Cup (in Sangju)',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(662,'South Korea KBL Final',1,7,2,null,2,null,null,'',0,0,null,null,12000,9000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(663,'South Korea WKBL (New)',1,7,3,null,3,null,null,'',0,0,null,null,3000,3000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(664,'South Korea WKBL All Star Game',1,7,2,null,3,null,null,'',0,0,null,null,2000,1000,null,null,1,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(665,'South Korea WKBL Final',1,7,2,null,3,null,null,'',0,0,null,null,6500,5200,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(666,'Spain ACB',1,8,3,null,3,null,null,'',0,0,null,null,5000,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(667,'Spain ACB Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(668,'Spain Adecco Oro',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(669,'Spain Copa Castilla y Leon',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(670,'Spain Copa Castilla y Leon LEB Oro',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(671,'Spain Copa Castilla y Leon LEB Plata',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(672,'Spain Copa Del Rey',1,8,3,null,3,null,null,'',0,0,null,null,2000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(673,'Spain LEB Oro',1,8,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(674,'Spain LEB Plata',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(675,'Spain Liga 2 Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(676,'Spain Liga Catalana ACB',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(677,'Spain Liga Catalana EBA',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(678,'Spain Liga Catalana LEB Plata ',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(679,'Spain Liga Challenge Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(680,'Spain Liga EBA',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(681,'Spain Liga Women',1,8,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(682,'Spain Supercopa',1,8,4,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(683,'Spain Women League',1,8,4,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(684,'Stankovic Continental Cup (in China)',1,7,3,null,null,null,null,'',0,0,null,null,4500,3000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(685,'Summer Super 8 (in Macau)',1,7,3,null,null,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(686,'Sweden Basketligan',1,8,4,null,3,null,null,'(Not Offer Quarters)',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,null,null,null,null,null,null,null,null),
(687,'Sweden Basketligan Women',1,8,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(688,'Sweden Superettan',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(689,'Sweden Superettan Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(690,'Switzerland NLB',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(691,'Switzerland SBL',1,8,4,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(692,'Switzerland SBL Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(693,'Switzerland SBLW',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(694,'Switzerland Super Cup',1,8,4,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(695,'Switzerland Super Cup Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(696,'Syria Basketball Cup',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(697,'Taiwan P.League+',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(698,'Taiwan SBL',1,7,4,null,3,null,null,'',0,0,null,null,1500,1200,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(699,'Taiwan Super Basketball Challenge',1,7,4,null,3,null,null,'(Not Offer Quarters)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null, null,null,1,1,1,null,1,1,1,null,null,null,null,null,null,null,null),
(700,'Taiwan T1 League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(701,'Taiwan UBA Men',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(702,'Taiwan UBA Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(703,'Taiwan WSBL',1,7,6,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(704,'Thailand 3x3 Basketball League',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(705,'Thailand 3x3 Basketball League Women',1,3,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(706,'Thailand 3x3 EXE Premier',1,3,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(707,'Thailand 3x3 Super League',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(708,'Thailand 3x3 Super League Women',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(709,'Thailand Basketball League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(710,'Thailand Basketball League (in Nimibutr Stadium)',1,7,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,500,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(711,'Thailand Basketball League (in Prachaniwet)',1,7,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(712,'Thailand Basketball League (in RMUTR, Nakhon Pathom)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(713,'Thailand Basketball League (in Stadium 29)',1,7,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(714,'Thailand Basketball League (in Thung Khru)',1,7,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(715,'Thailand Basketball League Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(716,'Thailand Basketball Super League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(717,'Thailand Open Basketball',1,7,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(718,'Thailand Professional League',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(719,'The Terrific 12 (in Macau)',1,7,3,null,null,null,null,'',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(720,'Tunisia Pro A League',1,7,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(721,'Tunisia Pro A League Women',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(722,'Turkey 2.Ligi',1,8,5,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(723,'Turkey BSL',1,8,3,null,3,null,null,'',0,0,null,null,2300,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(724,'Turkey Cup',1,8,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(725,'Turkey EBBL',1,8,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(726,'Turkey Federation Cup (in Ankara)',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(727,'Turkey Federation Cup (in Kocaeli)',1,8,5,null,3,null,null,'',0,0,null,null,1000,800,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(728,'Turkey Federation Cup Women (in Ankara)',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(729,'Turkey KBBL Women',1,8,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(730,'Turkey KBSL Women',1,8,4,null,5,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(731,'Turkey TBL',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(732,'Turkey TKBL Women',1,8,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(733,'UAE - Arabian Gulf Club Championship',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(734,'Uganda NBL Women',1,8,5,null,5,null,null,'',0,0,40,40,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(735,'Ukraine FBU Superleague',1,8,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(736,'Ukraine Korban Cup',1,8,6,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(737,'University 3x3 Basketball Championship (in Chinese Taipei)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(738,'University 3x3 Basketball Championship Women (in Chinese Taipei)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(739,'Uruguay Liga Women',1,5,5,null,5,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(740,'Uruguay LUB',1,5,5,null,5,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(741,'Uruguay Metro League',1,5,3,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(742,'Utsunomiya Final 2019 (02-NOV-2019)',1,4,3,null,1,null,null,'',0,0,null,null,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(743,'Venezuela - Super Liga Women',1,5,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(744,'Venezuela Superliga',1,5,4,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(745,'Vietnam National League (in Nha Trang)',1,7,5,null,3,null,null,'',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(746,'Vietnam National League Women (in Nha Trang)',1,7,5,null,3,null,null,'',0,0,null,null,750,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(747,'Vietnam VBA',1,7,4,null,3,null,null,'',0,0,null,null,3000,2000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(748,'Vietnam VBA',1,7,4,null,3,null,null,'',0,0,null,null,1200,900,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(749,'Vietnam VBA',1,7,4,null,3,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(750,'Vietnam VBA - Challenger Game',1,7,4,null,3,null,null,'',0,0,null,null,2000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(751,'VTB United League',1,8,3,null,3,null,null,'',0,0,null,null,3000,2300,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(752,'VTB United League Super Cup',1,8,6,null,3,null,null,'',0,0,null,null,1500,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(753,'VTB United Youth League',1,8,5,null,3,null,null,'(Deposit Site Only)',0,0,null,null,1000,1000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,null,null),
(754,'William Jones Cup Men (in Chinese Taipei)',1,7,3,null,3,null,null,'',0,0,null,null,5000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(755,'William Jones Cup Women (in Chinese Taipei)',1,7,3,null,3,null,null,'',0,0,null,null,5000,4000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(756,'WNBA All Star Game',1,9,1,null,2,null,null,'',0,0,null,null,5000,5000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(757,'WNBA Final',1,9,1,null,2,'01:00',null,'',0,0,null,null,10000,10000,null,null,null,null,1,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(758,'WNBA PlayOffs',1,9,1,null,2,'01:00',null,'',0,0,null,null,20000,20000,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(759,'WNBA Pre Season',1,9,1,null,2,null,null,'',0,0,null,null,5000,3000,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,1,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(760,'WNBA Pre Season',1,9,1,null,2,null,null,'',0,0,null,null,8000,5000,null,null,null,null,null,null,null,1,null,null,null,null,null,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(761,'WNBA Regular Season',1,9,1,null,2,null,null,'',0,0,null,null,20000,15000,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,1,null,null,null,1,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(762,'Xichang International Basketball Championship Women (in China)',1,7,3,null,null,null,null,'',0,0,null,null,2000,1500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(763,'Xiongan 2019 (23-AUG-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(764,'Yekaterinburg 2019 (09-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,500,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(765,'Yichang 2019 (13-JUL-2019)',1,2,3,null,1,null,null,'',0,0,null,null,750,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,1,null,1,null,null,null,null,null,null,null,null,null,null,null,null),
(766,'Zadar Basketball Tournament (in Croatia)',1,10,3,null,3,null,null,'(Below 15p [3000] [2000])(Above 15p [2000] [1500])',0,0,null,null,3000,2000,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,1,null,null,null,null,null,null, null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null),
(767,'Algeria - Coupe de Algerie',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(768,'Argentina La Liga Federal Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(769,'Argentina Torneo Federal Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(770,'Bahrain Federation Cup',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(771,'Brazil Campeonato Carioca U19',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(772,'Brazil Campeonato Paulista U20',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(773,'Brazil Copa Santa Catarina U20',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(774,'Brazil LSB Liga B',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(775,'Brazil Streetopia',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(776,'Canada Elite Basketball League',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(777,'Chile LNF Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(778,'Cyprus Division A',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(779,'El Salvador LMBF Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(780,'El Salvador LNB Tercera',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(781,'Guatemala Liga Metropolitana',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(782,'Guatemala Primera Division',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(783,'International Liga Unike',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(784,'Italy Regional U20',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(785,'Italy U20 League',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(786,'Kenya Premier League',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(787,'Kosovo Super Cup',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(788,'Leba0n Division 1 Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(789,'Luxembourg - Nationale 1',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(790,'Montenegro Montenegrin Basketball League',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(791,'Morocco Basketball League',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(792,'Morocco Division Excellence',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(793,'Morocco Division Excellence Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(794,'Morocco First Division Nationale',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(796,'Nicaragua Carlos Ulloa in Memoriam',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(797,'Nicaragua LAE Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(798,'Philippines NAASCU',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(799,'Portugal Proliga',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(800,'Russia DUBL U19 Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(801,'Uganda Division 1 Women',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(802,'Uganda NBL',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(803,'USA The Basketball Tournament',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null),
(804,'Vietnam Lee Sport Cup (in Phu Nhuan)',0,null,null,null,null,null,null,'',0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)

SELECT DISTINCT 
       l.OsleagueName, 
       l.IsActive, 
	   l.Regions,
	   l.Category
INTO OsLeageInfoTemp
FROM OsLeagueTemp l;


--insert/update OSLeague 
MERGE OSLeague AS l
USING OsLeageInfoTemp AS temp
ON(TRIM(l.LeagueName) = TRIM(temp.OsleagueName))
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT(LeagueName, 
             IsActive,
			 RegionId,
			 CategoryId)           
      VALUES
(temp.OsleagueName, 
 temp.IsActive,
 temp. Regions,      
 temp.Category      
)
    WHEN MATCHED
    THEN UPDATE SET 
                    l.IsActive = temp.IsActive,
					l.RegionId = temp.Regions,
					l.CategoryId = temp.Category;
					
                 


-- insert OsLeagueSetting
SET IDENTITY_INSERT OSLeagueSetting ON;

INSERT INTO OSLeagueSetting
(LeagueSettingId, 
 OSLeagueId, 
 WeekMatchId, 
 BetDelayId, 
 KOFromTime, 
 KOToTime, 
 Remark, 
 IsManualUpdateScore, 
 IsIptvOnly, 
 MaxbetHDP, 
 MaxbetOU, 
 SpreadHDP, 
 SpreadOU
)
       SELECT DISTINCT 
              t.OsLeagueSettingId, 
              l.OSLeagueId, 
              t.WeekMatchId, 
              t.BetDelay, 
              t.KOFrom, 
              t.KOTo, 
              t.Remark, 
              t.ManualUpdScore, 
              t.IPTVOnly, 
              t.MaxbetHDP, 
              t.MaxbetOU, 
              t.SpreadHDP, 
              t.SpreadOU
       FROM OsLeagueTemp t
            INNER JOIN OSLeague l ON t.OsleagueName = l.LeagueName;
SET IDENTITY_INSERT OSLeagueSetting OFF;




--insert OSSettingOfferLine
INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 1 FROM OsLeagueTemp t 
WHERE t.Offer1lines is not null 

INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 2 FROM OsLeagueTemp t 
WHERE t.Offer2lines is not null 

INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 3 FROM OsLeagueTemp t 
WHERE t.Offer3lines is not null 

INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 4 FROM OsLeagueTemp t 
WHERE t.Offer6lines is not null 

INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 6 FROM OsLeagueTemp t 
WHERE t.HDP3Line is not null 

INSERT INTO OSSettingOfferLine  
SELECT t.OsLeagueSettingId, 10 FROM OsLeagueTemp t 
WHERE t.OU6Line is not null 

-- insert OSSettingRound
INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 1 FROM OsLeagueTemp t 
WHERE t.PreSeason is not null 

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 2 FROM OsLeagueTemp t 
WHERE t.RegularSeason is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 3 FROM OsLeagueTemp t 
WHERE t.Consolation is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 4 FROM OsLeagueTemp t 
WHERE t.PlayOff is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 5 FROM OsLeagueTemp t 
WHERE t.Semifinal is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 6 FROM OsLeagueTemp t 
WHERE t.Final is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 7 FROM OsLeagueTemp t 
WHERE t.AllStarGame is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 8 FROM OsLeagueTemp t 
WHERE t.[Classification] is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 9 FROM OsLeagueTemp t 
WHERE t.Qualification is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 10 FROM OsLeagueTemp t 
WHERE t.GroupPhase is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 11 FROM OsLeagueTemp t 
WHERE t.QuaterFinal is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 12 FROM OsLeagueTemp t 
WHERE t.FirstRound is not null
   
INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 13 FROM OsLeagueTemp t 
WHERE t.SecoundRound is not null

INSERT INTO OSSettingRound  
SELECT t.OsLeagueSettingId, 14 FROM OsLeagueTemp t 
WHERE t.ThridPlace is not null



-- insert OSSettingProvider
INSERT INTO OSSettingProvider  
SELECT t.OsLeagueSettingId, 1 FROM OsLeagueTemp t 
WHERE t.ProviderCMT is not null

INSERT INTO OSSettingProvider  
SELECT t.OsLeagueSettingId, 2 FROM OsLeagueTemp t 
WHERE t.ProviderVenue is not null

INSERT INTO OSSettingProvider  
SELECT t.OsLeagueSettingId, 3 FROM OsLeagueTemp t 
WHERE t.ProviderTV is not null

--insert  OSSettingBettype
INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 1 FROM OsLeagueTemp t 
WHERE t.TypeMNL is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 2 FROM OsLeagueTemp t 
WHERE t.TypeHDP is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 3 FROM OsLeagueTemp t 
WHERE t.TypeOU is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 4 FROM OsLeagueTemp t 
WHERE t.TypeOE is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 5 FROM OsLeagueTemp t 
WHERE t.Type1HMNL is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 6 FROM OsLeagueTemp t 
WHERE t.Type1HHDP is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 7 FROM OsLeagueTemp t 
WHERE t.Type1HOU is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 8 FROM OsLeagueTemp t 
WHERE t.Type1HOE is not null


INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 9 FROM OsLeagueTemp t 
WHERE t.Type13MNL is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 10 FROM OsLeagueTemp t 
WHERE t.Type13HDP is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 11 FROM OsLeagueTemp t 
WHERE t.Type13OU is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 12 FROM OsLeagueTemp t 
WHERE t.Type13OE is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 13 FROM OsLeagueTemp t 
WHERE t.Type24MNL is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 14 FROM OsLeagueTemp t 
WHERE t.Type24HDP is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 15 FROM OsLeagueTemp t 
WHERE t.Type24OU is not null

INSERT INTO OSSettingBettype  
SELECT t.OsLeagueSettingId, 16 FROM OsLeagueTemp t 
WHERE t.Type24OE is not null

DROP TABLE OsLeagueTemp;
DROP TABLE OsLeageInfoTemp;