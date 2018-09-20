/* =============================================
	Created: Julien@20170303
	Task: Insert assignment uploading
	DB: OWP
	
	Revision:
		-
-- =============================================*/
CREATE PROCEDURE [dbo].[OWP_RefResourceCheckExistsInsert]
	@ListValue NVARCHAR (MAX) --list value need to check & insert
	, @RefName VARCHAR (30)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #tmp (Name NVARCHAR(200))
	
	DECLARE @MaxId SMALLINT 
	
	SELECT @MaxId = CAST(MAX(ResourceId) AS INT)
	FROM RefResource rs WITH (NOLOCK) 
	WHERE rs.RefName = @RefName
	
	SET @MaxId = ISNULL(@MaxId,0)
	
	CREATE TABLE #TobeInserted (ResourceId SMALLINT IDENTITY(1,1)
		, Value NVARCHAR(200))


    INSERT INTO #tmp(Name)
	SELECT DISTINCT RTRIM(LTRIM(p.val))
	FROM dbo.fnc_SplitStrings(@ListValue, ',') p
	OPTION (MAXRECURSION 0)
	
	INSERT INTO #TobeInserted (Value)
	SELECT Name FROM #tmp
	WHERE ISNULL(Name, '') <> ''
	
	INSERT INTO RefResource (RefName, ResourceId, Value)
	SELECT @RefName, @MaxId + t.ResourceId, t.Value
	FROM #TobeInserted t
		LEFT JOIN RefResource rs WITH (NOLOCK)
			ON t.Value = rs.Value AND rs.RefName = @RefName
	WHERE rs.ResourceId IS NULL
	
	DROP TABLE #tmp
	
END