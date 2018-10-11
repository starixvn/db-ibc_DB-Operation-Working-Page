/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_SplitStrings](@string nvarchar(max),@splitter nvarchar(max))
/*          
Created: 00000000@User.Name
Task : split strings
DB: bodb_OWP

Param's Explanation:    
	You need to use option: option (maxrecursion 0) at the statement if the lengh of string exceed 100 levels  

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]  
	                 
*/        
RETURNS TABLE
AS
RETURN
    WITH cte AS(
        SELECT	CAST(0 AS BIGINT) as idx1,CHARINDEX(@splitter,@string) idx2
        UNION ALL
        SELECT	idx2 + LEN(@splitter)
			, CHARINDEX(@splitter, @string, idx2 + LEN(@splitter))
        FROM	cte
        WHERE	idx2 > 0
    )
    SELECT	SUBSTRING(@string, idx1, COALESCE(NULLIF(idx2,0) ,LEN(@string) + 1) - idx1) as val
    FROM	cte