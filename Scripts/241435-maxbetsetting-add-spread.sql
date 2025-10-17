/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251017@Hank
Task : Add columns to MaxbetSetting table for spread
DB: bodb_OWP	

Revisions:
	 20251017@Hank: Add columns to MaxbetSetting table for spread - [Redmine: #241435]
*/
USE bodb_OWP
GO

ALTER TABLE MaxbetSetting
ADD NoOfCorner_FT_Spread_HDP SMALLMONEY NULL,
	NoOfCorner_FT_Spread_OU SMALLMONEY NULL,
	NextCorner_FT_Spread_HDP SMALLMONEY NULL,
	TotalBooking_FT_Spread_HDP SMALLMONEY NULL,
	TotalBooking_FT_Spread_OU SMALLMONEY NULL,
	NextBooking_FT_Spread_HDP SMALLMONEY NULL
GO