/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20240227@Mira
Task : Remove CN88 text in LST Note
DB: bodb_OWP

Revisions:
	20240227@Mira: Remove CN88 text in LST Note - [Redmine: #201386]
*/

UPDATE NewLeagueSetting
SET LSTNote = 
    CASE
        WHEN LSTNote LIKE '%(MBC & CN88 MB Fixed),%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(MBC & CN88 MB Fixed),', '')))
		WHEN LSTNote LIKE '%(MBC & CN88 MB Fixed)\_%' ESCAPE '\' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(MBC & CN88 MB Fixed)_', '')))
		WHEN LSTNote LIKE '%(MBC & CN88 MB Fixed)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(MBC & CN88 MB Fixed)', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed) -%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed) -', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed) ,%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed) ,', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed),%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed),', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed).%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed).', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed)\_%' ESCAPE '\' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed)_', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed) ;%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed) ;', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed)', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed Weekend);%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed Weekend);', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed Weekend),%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed Weekend),', '')))
		WHEN LSTNote LIKE '%(CN88 MB Fixed Weekend)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB Fixed Weekend)', '')))
		WHEN LSTNote LIKE '%(CN88 SP Fixed),%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 SP Fixed),', '')))
		WHEN LSTNote LIKE '%(CN88 SP Fixed)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 SP Fixed)', '')))
		WHEN LSTNote LIKE '%(CN88 MB/SP Fixed)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88 MB/SP Fixed)', '')))
		WHEN LSTNote LIKE '%(CN88MB Fixed Weekend),%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88MB Fixed Weekend),', '')))
		WHEN LSTNote LIKE '%(CN88MB Fixed Weekend)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '(CN88MB Fixed Weekend)', '')))
		WHEN LSTNote LIKE '%28-Oct-19 : 2nd Round CN88 maxbet follow MBC first (Yong Inf)%' THEN LTRIM(RTRIM(REPLACE(LSTNote, '28-Oct-19 : 2nd Round CN88 maxbet follow MBC first (Yong Inf)', '')))
		ELSE LSTNote
             END
WHERE LSTNote LIKE '%CN88%';