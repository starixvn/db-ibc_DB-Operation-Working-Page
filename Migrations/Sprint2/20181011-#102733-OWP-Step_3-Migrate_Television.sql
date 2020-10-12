/*
	Creator:	20181009@Leo
	Task:		Data migration for new OWP - Television table - [Redmine: #102733]
	Server:		DBOWP.bodb_OWP

	Review & Tested:	Billy
*/


CREATE TABLE	#tblTelevision (
					TVCode	NVARCHAR(100)
				,	Color	VARCHAR(20)
				);

-- 1974 rows affected --
INSERT INTO	#tblTelevision (TVCode, Color)
SELECT	RTRIM(LTRIM(REPLACE(REPLACE(TVCode, CHAR(13), ''), CHAR(10), '')))
	,	Color
FROM	dbo.Television_Old WITH (NOLOCK);

-- 1567 rows affected --
INSERT INTO	dbo.Television (TVCode)
SELECT	DISTINCT
		TVCode
FROM	#tblTelevision
WHERE	TVCode NOT IN ('', '.', '?', '`');

-- 88 rows affected --
UPDATE	tv WITH (ROWLOCK, UPDLOCK)
SET		tv.Color = t1.Color
FROM		dbo.Television AS tv
INNER JOIN	#tblTelevision AS t1 WITH (NOLOCK)
		ON	tv.TVCode = t1.TVCode
		AND	tv.Color <> t1.Color;

DROP TABLE	#tblTelevision;