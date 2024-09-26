
/*<info serverAlias="DBOWP-bodb_OWP" selecters="wsv_owp" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[fnc_GetRefResourceByIds] (@RefResourceId VARCHAR(2000) = '', @RefResourceName VARCHAR(30) = '')
RETURNS @tblRefResource TABLE (
	RefResourceId INT NOT NULL
	,RefResourceValue VARCHAR(50)
	)
AS
/*          
Created: 20200714@Tyler.Dang
Task : get RefResource by Ids
DB: bodb_OWP

Revisions:
	20200714@Tyler.Dang: Initial Func - [Redmine: #137416]
*/
BEGIN
	IF LEN(ISNULL(@RefResourceId, '')) = 0
	BEGIN
		INSERT INTO @tblRefResource
		SELECT ResourceId
			,Value
		FROM dbo.RefResource AS rs WITH (NOLOCK)
		WHERE RefName = @RefResourceName
		ORDER BY rs.[Order]
			,rs.[Value];

		INSERT INTO @tblRefResource
		VALUES (
			0
			,'None'
			);
	END;
	ELSE
	BEGIN
		INSERT INTO @tblRefResource
		SELECT ISNULL(ResourceId, 0)
			,ISNULL(Value, 'None')
		FROM dbo.fnc_SplitStrings(@RefResourceId, ',')
		LEFT JOIN dbo.RefResource AS rs WITH (NOLOCK) ON RefName = @RefResourceName
			AND val = ResourceId
			ORDER BY rs.[Order]
			,rs.[Value];
	END;

	RETURN
END