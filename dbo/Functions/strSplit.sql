CREATE FUNCTION [dbo].[strSplit] (
	 @string NVARCHAR(MAX)
	,@splitter NVARCHAR(255)
	)
RETURNS TABLE
	WITH SCHEMABINDING
AS
RETURN (
		SELECT rank = ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), val = y.i.value('(./text())[1]', 'nvarchar(max)')
		FROM (
			SELECT x = CONVERT(XML, '<i>' + REPLACE(REPLACE(@string,'&', '&amp;'), @splitter, '</i><i>') + '</i>').query('.')
			) AS a
		CROSS APPLY x.nodes('i') AS y(i)
		);