
/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_SplitString] (@string nvarchar(max),@splitter nvarchar(max))
	/*          
Created: 20190210@Leo.Vo
Task : split strings
DB: bodb_OWP

Revisions:
	20190210@Leo.Vo: Initial - [Redmine: #120415]  
	20191008@Billy: Switch to bodb02 version of split string - [Redmine: #000000]
	                 
*/
RETURNS TABLE
AS
RETURN
	WITH cte AS(
		SELECT	CAST(0 AS BIGINT) as idx1,CHARINDEX(@splitter, @string) idx2
		UNION ALL
		SELECT	idx2 + LEN(@splitter), CHARINDEX(@splitter, @string, idx2 + LEN(@splitter))
		FROM	cte
		WHERE	idx2 > 0
	)
	SELECT	SUBSTRING(@string,idx1,COALESCE(NULLIF(idx2,0),LEN(@string)+1)-idx1) as Value
	FROM	cte