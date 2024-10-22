/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20210128@Carlos
Task : Display Match Code on Task List and LGA & Live Game LIst
DB: bodb_OWP	

Revisions:
	20210128@Carlos: Display Match Code on Task List and LGA - [Redmine: #149347]
*/

ALTER TABLE InfoSiteMatch
ADD MatchCode NVARCHAR(50)
     
ALTER TABLE OWPMatch
ADD MatchCode NVARCHAR(50)




