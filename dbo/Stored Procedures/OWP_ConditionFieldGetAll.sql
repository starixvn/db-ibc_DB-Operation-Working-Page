CREATE PROCEDURE [dbo].[OWP_ConditionFieldGetAll]
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

	SELECT FieldId
		,NAME
		,[Text]
		,IsRequired
	FROM dbo.FilterField WITH (NOLOCK)
	WHERE Name <> 'IsSelected'
END