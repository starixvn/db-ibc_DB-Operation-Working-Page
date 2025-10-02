/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20251002@Frankie
Task : Update MaxBet & Spread Column Layout
DB: bodb_OWP	

Revisions:
	20251002@Frankie: insert new data and update column order table OSBetDelayOption- [Redmine: #239944]
	
*/
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 1s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 3s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 5s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 7s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 9s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 11s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 13s',NULL)
  insert into [bodb_OWP].[dbo].[OSBetDelayOption] values ('Bet Delay 14s',NULL)

  update [bodb_OWP].[dbo].[OSBetDelayOption] set [Order] = NULL

  UPDATE [bodb_OWP].[dbo].[OSBetDelayOption]
	SET [Order] = CAST(
		REPLACE(
			REPLACE("Label", 'Bet Delay ', ''),
			's', ''
		) AS INTEGER
	);
