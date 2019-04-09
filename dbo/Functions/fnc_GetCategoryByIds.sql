
/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetCategoryByIds] (@CategoryId VARCHAR(2000) = '')
RETURNS @tblCategory TABLE (
	CategoryId INT
	,CategoryName VARCHAR(50)
	)
AS
/*          
Created: 20190408@Raymond.Le
Task : get table category by Ids
DB: bodb_OWP

Param's Explanation:    
	@CategoryId = N'1,2,3,4'; 

Revisions:
	20190408@Raymond.Le: Initial Func - [Redmine: #111068]	                 
*/
BEGIN
	IF LEN(ISNULL(@CategoryId, '')) = 0
	BEGIN
		INSERT INTO @tblCategory
		SELECT ResourceId
			,Value
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = 'UserCategory';

		INSERT INTO @tblCategory
		VALUES (
			0
			,'None'
			);
	END;
	ELSE
	BEGIN
		INSERT INTO @tblCategory
		SELECT ISNULL(ResourceId, 0)
			,ISNULL(Value, 'None')
		FROM dbo.fnc_SplitStrings(@CategoryId, ',')
			LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'UserCategory'
			AND val = ResourceId
	END;

	RETURN
END