-- remove column RefResourceId
ALTER TABLE dbo.RefResource
DROP COLUMN RefResourceId


-- init data MatchOffer in table RefResource
INSERT INTO dbo.RefResource(RefName, ResourceId, [Value])
VALUES ('MatchOffer', 1, 'KO+15'), ('MatchOffer', 2, 'Fast Market'), ('MatchOffer', 3, '10s Accept'), ('MatchOffer', 4, '15s Accept'), ('MatchOffer', 5, '20s Accept')

-- migrate data for MatchOffer 'KO+15' & 'Fast Market'
INSERT INTO dbo.MatchOfferDetail (
	OWPMatchId
	,MatchOffer
	)
SELECT mi.OWPMatchId
	,r.ResourceId
FROM dbo.MatchInfo AS mi WITH (NOLOCK)
	INNER JOIN dbo.RefResource AS r WITH (NOLOCK) ON mi.KOTimeRemark = r.[Value]
	AND r.RefName = 'MatchOffer'

-- migrate data for MatchOffer 'KO+15 Fast Market'
INSERT INTO dbo.MatchOfferDetail (OWPMatchId, MatchOffer)
SELECT mi.OWPMatchId
	,r.ResourceId
FROM (
	SELECT OWPMatchId
	FROM dbo.MatchInfo WITH (NOLOCK)
	WHERE KOTimeRemark = 'KO+15 Fast Market'
	) AS mi
	CROSS JOIN (
	SELECT ResourceId
	FROM dbo.RefResource WITH (NOLOCK)
	WHERE RefName = 'MatchOffer'
		AND [Value] IN ('KO+15', 'Fast Market')
	) AS r