
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211028@Mira
Task : Add 12s Accept
DB: bodb_OWP	

Revisions:
	20211028@Mira: Add 12s Accept - [Redmine: #163824]
*/

-- LA Report
INSERT INTO RefResource
([RefName], 
 [ResourceId], 
 [Value], 
 [Order]
)
VALUES
('MatchOffer', 
 9, 
 '12s Accept', 
 0
);