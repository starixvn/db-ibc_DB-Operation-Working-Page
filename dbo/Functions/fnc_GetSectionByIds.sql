/*<info serverAlias="DBOWP-bodb_OWP" selecters="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetSectionByIds](@SectionId VARCHAR(2000) = '')
RETURNS @tblSection TABLE (SectionId INT NOT NULL, SectionName VARCHAR(50))
AS
/*          
Created: 20190408@Raymond.Le
Task : get table setion by Ids
DB: bodb_OWP

Param's Explanation:    
	@SectionId = N'1,2,3,4'; 

Revisions:
	20190408@Raymond.Le: Initial Func - [Redmine: #111068]	                 
*/        
BEGIN
	IF LEN(ISNULL(@SectionId, '')) = 0
	BEGIN
		INSERT INTO @tblSection
		SELECT ResourceId
			,Value
		FROM dbo.RefResource WITH (NOLOCK)
		WHERE RefName = 'Section';

		INSERT INTO @tblSection
		VALUES (
			0
			,'None'
			);
	END;
	ELSE
	BEGIN
		INSERT INTO @tblSection
		SELECT ISNULL(ResourceId, 0)
			,ISNULL(Value, 'None')
		FROM dbo.fnc_SplitStrings(@SectionId, ',')
			LEFT JOIN dbo.RefResource WITH (NOLOCK) ON RefName = 'Section'
			AND val = ResourceId
	END;
	RETURN
END