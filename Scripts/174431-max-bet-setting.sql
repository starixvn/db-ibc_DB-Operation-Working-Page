/*
Created: 20220701@Carlos
Task : Get OS league category option
DB: bodb_OWP

Revisions:
	20220701@Carlos: Initial - [Redmine: #174431]	
*/

/*
DROP TABLE OSLeagueSetting
DROP TABLE OSBasketballInfo
DROP TABLE OSRegionOption
DROP TABLE OSCategoryOption
DROP TABLE OSRoundOption
DROP TABLE OSWeekMatchOption
DROP TABLE OSOfferLineOption
DROP TABLE OSBetDelayOption
DROP TABLE OSProviderOption
DROP TABLE OSStatusOption
DROP TABLE OSBettypeOption
*/

CREATE TABLE OSLeagueSetting(
	LeagueSettingId INT IDENTITY(1,1) PRIMARY KEY,
	OSLeagueId INT NOT NULL,
	RegionId INT,
	CategoryId INT,
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
   ADD  IsActive BIT NOT NULL DEFAULT(0)

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
('Minor 4')

INSERT INTO OSRegionOption(Label)
VALUES
('3x3 Challenge'),
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
('Bet Delay 15s')

INSERT INTO OSProviderOption(Label)
VALUES
('CMT'),
('Venue Feed'),
('TV Feed')
