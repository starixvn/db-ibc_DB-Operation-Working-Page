
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20211231@Liam.Pham
Task : New Columns for esoccer
DB: bodb_OWP	

Revisions:
	20220120@Liam.Pham: add columns for esoccer - [Redmine: #167636]	
*/

ALTER TABLE TraderReport
ADD Esoccer_5mins  INT, 
    ESoccer_6Mins  INT, 
    ESoccer_15Mins INT, 
    ESoccer_16Mins INT, 
    ESoccer_20Mins INT;
