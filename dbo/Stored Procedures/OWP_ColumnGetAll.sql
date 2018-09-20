CREATE PROCEDURE[dbo].[OWP_ColumnGetAll]
AS
/*
Created: 20161220@Razor.Nguyen
Task : Get 
DB: bodb_OWP

Revisions:
Param's Explanation:
   
*/
BEGIN
	SET NOCOUNT ON

	SELECT ColumnId
		,[Name]
		,[Text]
		,IsDefaultSelected
		,ParentColumnId
		,DisplayOrder
	FROM dbo.[Column] WITH (NOLOCK)
	WHERE IsActive = 1
END