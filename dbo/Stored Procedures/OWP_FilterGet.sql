/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE[dbo].[OWP_FilterGet] @UserId INT = 0
AS
/*      
 Created: 20161220@Razor.Nguyen
 Task : Insert new filter  
 DB: bodb_OWP      
      
 Revisions:          
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
*/
BEGIN
	SET NOCOUNT ON

	SELECT f.FilterId
		,f.FilterName AS [Name]
		,(CASE 
			WHEN def.UserId = @UserId THEN 1
			WHEN def.UserId <> @UserId
				OR def.UserId IS NULL THEN 0 END
			) AS IsDefault
		,(CASE 
			WHEN f.CreatedBy = @UserId THEN 1
			ELSE 0 END
			) AS IsOwner
	FROM dbo.Filter AS f WITH (NOLOCK)
		LEFT JOIN dbo.FilterUserDefault AS def WITH (NOLOCK) ON def.FilterId = f.FilterId
		AND def.UserId = @UserId
	WHERE f.CreatedBy = @UserId
		OR (
			f.CreatedBy <> @UserId
			AND f.IsPublic = 1
			)
END