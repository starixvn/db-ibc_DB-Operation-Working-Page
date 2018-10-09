/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[strSplit] (
	 @string NVARCHAR(MAX)
	,@splitter NVARCHAR(255)
	)
RETURNS TABLE
	WITH SCHEMABINDING
AS
/*
Created: 00000000@User.Name
Task : string split
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
 
*/
RETURN (
		SELECT rank = ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), val = y.i.value('(./text())[1]', 'nvarchar(max)')
		FROM (
			SELECT x = CONVERT(XML, '<i>' + REPLACE(REPLACE(@string,'&', '&amp;'), @splitter, '</i><i>') + '</i>').query('.')
			) AS a
		CROSS APPLY x.nodes('i') AS y(i)
		);