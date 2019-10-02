
/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_SplitString] (
	@List NVARCHAR(max)
	,@Delim NVARCHAR(255)
	)
	/*          
Created: 20190210@Leo.Vo
Task : split strings
DB: bodb_OWP

Revisions:
	20190210@Leo.Vo: Initial - [Redmine: #120415]  
	                 
*/
RETURNS TABLE
AS
RETURN (
		SELECT [Value]
		FROM (
			SELECT [Value] = LTRIM(RTRIM(SUBSTRING(@List, [Number], CHARINDEX(@Delim, @List + @Delim, [Number]) - [Number])))
			FROM (
				SELECT Number = ROW_NUMBER() OVER (
						ORDER BY NAME
						)
				FROM sys.all_columns
				) AS x
			WHERE Number <= LEN(@List)
				AND SUBSTRING(@Delim + @List, [Number], DATALENGTH(@Delim) / 2) = @Delim
			) AS y
		);