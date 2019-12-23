/*
	Created: 
	Date: 
	Task: data [Redmine: #]
	DB: bodb_OWP
*/

USE bodb_OWP;
GO

-- migrate column Market
DECLARE @tblMarket TABLE (
	Id INT
	,Value NVARCHAR(200)
	)

INSERT INTO @tblMarket (
	Id
	,Value
	)
SELECT ResourceId
	,Value
FROM dbo.RefResource WITH (NOLOCK)
WHERE RefName = 'Market'

CREATE TABLE #tblMatch (OWPMatchId INT PRIMARY KEY)

INSERT INTO #tblMatch (OWPMatchId)
SELECT DISTINCT OWPMatchId
FROM dbo.MatchMarket WITH (NOLOCK)

UPDATE mi WITH (ROWLOCK)
SET mi.Market = STUFF((
			SELECT ', ' + mk.Value
			FROM dbo.MatchMarket AS mm WITH (NOLOCK)
				INNER JOIN @tblMarket AS mk ON mm.MarketId = mk.Id
			WHERE mm.OWPMatchId = m.OWPMatchId
			FOR XML PATH('')
			), 1, 2, '')
FROM dbo.MatchInfo AS mi
	INNER JOIN #tblMatch AS m ON mi.OWPMatchId = m.OWPMatchId

DROP TABLE #tblMatch

INSERT INTO dbo.Module (ModuleId, ModuleName)
VALUES(8, 'OddsCompiler')
GO

INSERT INTO dbo.ModuleObject (ModuleObjectId, ModuleObjectName, ModuleId)
VALUES(30, 'Remark_OddsCompiler', 8)
GO

INSERT INTO dbo.LogAction (ActionId, ModuleId, ModuleObjectId, ActionTypeId, ActionName, SPName, LogItems)
VALUES(102, 8, 30,2, 'OWP_OddsCompiler_UpdateMarket', 'OWP_OddsCompiler_UpdateMarket', N'<root><xml path="r/z" /><row item="Market" alias="mk" /></root>')
GO

