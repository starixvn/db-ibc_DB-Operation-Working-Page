CREATE PROCEDURE[dbo].[OWP_ColumnGetByFilter] @FilterId INT
AS
/*
ALTERd: 20161220@Razor.Nguyen
Task : Get 
DB: bodb_OWP

Revisions:
Param's Explanation:
   
*/
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #tmpColumn(ColumnId INT)
	
	INSERT INTO #tmpColumn(ColumnId)
	SELECT f.ColumnId
	FROM dbo.FilterColumn AS f WITH (NOLOCK)
	WHERE f.FilterId = @FilterId

	SELECT c.ColumnId
		,c.[Name]
		,c.[Text]
		,c.IsAlwayDisplay
		,c.IsDefaultSelected
		,c.ParentColumnId
		,c.DisplayOrder
		,(CASE 
			WHEN f.ColumnId IS NOT NULL THEN 1
			ELSE 0 END
			) AS IsChecked
	FROM dbo.[Column] AS c WITH (NOLOCK)
		LEFT JOIN #tmpColumn AS f WITH (NOLOCK) ON c.ColumnId = f.ColumnId
	WHERE c.IsActive = 1
	
	DROP TABLE #tmpColumn
END