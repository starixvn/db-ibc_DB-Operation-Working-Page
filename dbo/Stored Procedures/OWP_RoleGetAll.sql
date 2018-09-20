CREATE PROCEDURE [dbo].[OWP_RoleGetAll]
AS
/*          
 Created: 20170214@Razor.Nguyen
 Task : Get All role
 DB: bodb_OWP          
          
 Revisions:      
         
*/
BEGIN
	SET NOCOUNT ON

	SELECT [RoleId]
		,[RoleName]
	FROM [dbo].[Role] WITH (NOLOCK)
END