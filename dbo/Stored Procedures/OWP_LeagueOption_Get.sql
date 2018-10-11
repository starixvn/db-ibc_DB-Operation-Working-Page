/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LeagueOption_Get] @Keywords NVARCHAR(100) = ''
AS
/*
Created: 20170301@Tim.Trinh
Task : select league option with search string
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: New structure of event assignment - [Redmine: #92868]
   
*/
BEGIN
	SET NOCOUNT ON

	SELECT POWER(2.0, opt.Value) AS OptionId
		,[Name] AS OptionName
		,ref.ResourceId AS CategoryId
		,ref.Value AS CategoryName
	FROM dbo.LeagueOption AS opt WITH (NOLOCK)
		LEFT JOIN dbo.RefResource AS ref WITH (NOLOCK) ON opt.CategoryId = ref.ResourceId
		AND ref.RefName = 'LeagueOptionCategory'
	WHERE opt.[Name] LIKE '%' + ISNULL(@Keywords, '') + '%'
		AND opt.OptionId > 2
END