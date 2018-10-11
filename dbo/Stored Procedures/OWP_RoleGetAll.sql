/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_RoleGetAll]
AS
/*          
Created: 20170214@Razor.Nguyen
Task : Get All role
DB: bodb_OWP          
          
Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]    
*/
BEGIN
	SET NOCOUNT ON

	SELECT [RoleId]
		,[RoleName]
	FROM [dbo].[Role] WITH (NOLOCK)
END