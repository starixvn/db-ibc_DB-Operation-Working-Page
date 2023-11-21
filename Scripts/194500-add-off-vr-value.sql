/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20231121@Johnny
Task : Add more values for Match Offer
DB: bodb_OWP

Revisions:
	20231121@Johnny: Init script - [Redmine: #194500]
*/


INSERT INTO [dbo].[RefResource]
([RefName], 
 [ResourceId], 
 [Value], 
 [Order]
)
VALUES
('MatchOffer', 41, 'OFF VR', 41),
('MatchOffer', 42, 'OFF VR (Whole Time)', 42),
('MatchOffer', 43, 'OFF VR 10 mins', 43),
('MatchOffer', 44, 'OFF VR HDP', 44),
('MatchOffer', 45, 'OFF VR HDP 10 mins', 45),
('MatchOffer', 46, 'If Big HDP > OFF VR', 46),
('MatchOffer', 47, 'If Big HDP > OFF VR 10 mins', 47)