USE bodb_OWP;
GO

CREATE TABLE SpecialProduct
(
	ProductId INT IDENTITY(1,1) PRIMARY KEY
	,Maxbet_FTHDP MONEY
	,Maxbet_NoOfCorner MONEY
	,Spread_NoOfCorner MONEY
	,Maxbet_NextCorner MONEY
	,Maxbet_10_15Mins MONEY
	,Spread_10_15Mins MONEY
	,Maxbet_TB MONEY
	,Spread_TB MONEY
	,Maxbet_NextTB MONEY
	,Spread_NextTB MONEY
	,Maxbet_PS MONEY
	,Spread_PS MONEY
	,Maxbet_Winner MONEY
	,Spread_Winner MONEY
	,Remark NVARCHAR(2000)
	,LastUpdate VARCHAR(255)
	,[Type] VARCHAR(10)
)
GO