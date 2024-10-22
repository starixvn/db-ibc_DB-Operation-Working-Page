
/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetSectionByIds] (@SectionId VARCHAR(2000) = '')
RETURNS @tblSection TABLE (
	SectionId INT NOT NULL
	,SectionName VARCHAR(50)
	)
AS
/*          
Created: 20190408@Raymond.Le
Task : get table setion by Ids
DB: bodb_OWP

Param's Explanation:    
	@SectionId = N'1,2,3,4'; 

Revisions:
	20190408@Raymond.Le: Initial Func - [Redmine: #111068]
	20190719@Kane.Le: Update Section Order - [Redmine: #117098]		                 
*/
BEGIN
	IF LEN(ISNULL(@SectionId, '')) = 0
	BEGIN
		INSERT INTO @tblSection
		SELECT ResourceId
			,Value
		FROM dbo.RefResource AS rs WITH (NOLOCK)
		WHERE RefName = 'Section'
		ORDER BY rs.[Order]
			,rs.[Value];

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
		LEFT JOIN dbo.RefResource AS rs WITH (NOLOCK) ON RefName = 'Section'
			AND val = ResourceId
			ORDER BY rs.[Order]
			,rs.[Value];
	END;

	RETURN
END