/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20230208@Mira
Task : Add more values for Second Accept Value
DB: bodb_OWP

Revisions:
	20230208@Mira: Add more values for Second Accept Value - [Redmine: #183242]
*/

UPDATE r
  SET 
      r.[Order] = (CASE Value
                      WHEN 'Fast Market' THEN 1
                      WHEN 'KO+15'		 THEN 2 
                      WHEN '10s Accept'	 THEN 12
                      WHEN '15s Accept'	 THEN 17
                      WHEN '20s Accept'	 THEN 22
                      WHEN '30s Accept'	 THEN 28
                      WHEN '5s Accept'	 THEN 7
					  WHEN '8s Accept'	 THEN 10
					  WHEN '12s Accept'	 THEN 14
					  WHEN '6s Accept'	 THEN 8
				ELSE 0
                END)
FROM dbo.RefResource r
WHERE RefName = 'MatchOffer';

INSERT INTO [dbo].[RefResource]
([RefName], 
 [ResourceId], 
 [Value], 
 [Order]
)
VALUES
('MatchOffer', 11, '1s Accept', 3),
('MatchOffer', 12, '2s Accept', 4),
('MatchOffer', 13, '3s Accept', 5),
('MatchOffer', 14, '4s Accept', 6),
('MatchOffer', 15, '7s Accept', 9),
('MatchOffer', 16, '9s Accept', 11),
('MatchOffer', 17, '11s Accept', 13),
('MatchOffer', 18, '13s Accept', 15),
('MatchOffer', 19, '14s Accept', 16),
('MatchOffer', 20, '16s Accept', 18),
('MatchOffer', 21, '17s Accept', 19),
('MatchOffer', 22, '18s Accept', 20),
('MatchOffer', 23, '19s Accept', 21),
('MatchOffer', 24, '21s Accept', 23),
('MatchOffer', 25, '22s Accept', 24),
('MatchOffer', 26, '23s Accept', 25),
('MatchOffer', 27, '24s Accept', 26),
('MatchOffer', 28, '25s Accept', 27),
('MatchOffer', 29, '35s Accept', 29),
('MatchOffer', 30, '40s Accept', 30),
('MatchOffer', 31, '45s Accept', 31),
('MatchOffer', 32, '50s Accept', 32),
('MatchOffer', 33, '55s Accept', 33),
('MatchOffer', 34, '60s Accept', 34),
('MatchOffer', 35, '65s Accept', 35),
('MatchOffer', 36, '70s Accept', 36),
('MatchOffer', 37, '75s Accept', 37),
('MatchOffer', 38, '80s Accept', 38),
('MatchOffer', 39, '85s Accept', 39),
('MatchOffer', 40, '90s Accept', 40)
