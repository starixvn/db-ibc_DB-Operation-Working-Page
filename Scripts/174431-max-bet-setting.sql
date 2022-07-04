/*DROP TABLE OSBasketballInfo
DROP TABLE OSBasketballRegionOption
DROP TABLE OSBasketballCategoryOption
DROP TABLE OSBasketballRoundOption
DROP TABLE OSBasketballWeekMatchOption
DROP TABLE OSBasketballOfferLineOption
DROP TABLE OSBasketballBetDelayOption
DROP TABLE OSBasketballProviderOption
DROP TABLE OSBasketballBettypeOption*/
CREATE TABLE OSLeagueSetting(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 LeagueId INT NOT NULL,
 Active BIT,
 RegionId INT,
 CategoryId INT,
 WeekMatchId INT,
 BetDelayId INT,
 KOFromTime TIME,
 KOToTime TIME,
 Remark VARCHAR(2000),
 ManualUpdateScore BIT,
 IptvOnly BIT
 )

 CREATE INDEX idx_league_id
ON OSLeagueSetting (LeagueId);

 CREATE INDEX idx_league_id
ON OSLeagueSetting (LeagueId);

 CREATE TABLE OSRegionOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSCategoryOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSRoundOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSWeekMatchOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSStatusOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSOfferLineOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSBetDelayOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSProviderOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSBettypeOption(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[label] VARCHAR(100)
)

CREATE TABLE OSLeagueRound(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	RoundId INT
)

CREATE INDEX idx_league_id
ON OSLeagueRound (LeagueSettingId);

CREATE TABLE OSLeagueOfferLine(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	OfferLineId INT
)

CREATE INDEX idx_league_id
ON OSLeagueOfferLine (LeagueSettingId);

CREATE TABLE OSLeagueProvider(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	ProviderId INT
)

CREATE INDEX idx_league_id
ON OSLeagueProvider (LeagueSettingId);


CREATE TABLE OSBettype(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	BettypeId INT
)

CREATE INDEX idx_league_id
ON OSBettype (LeagueSettingId);

CREATE TABLE OSLeagueMaxbet(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LeagueSettingId INT NOT NULL,
	MaxbetHDP MONEY,
	MaxbetOU MONEY,
	SpreadHDP MONEY,
	SpreadOU MONEY
)

CREATE INDEX idx_league_id
ON OSLeagueMaxbet (LeagueSettingId);

INSERT INTO OSBettypeOption([label])
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

INSERT INTO OSStatusOption([label])
VALUES ('Active'),
('Inactive')

INSERT INTO OSRoundOption([label])
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

INSERT INTO OSCategoryOption([label])
VALUES ('Major'),
('Minor 1'),
('Minor 2'),
('Minor 3'),
('Minor 4')