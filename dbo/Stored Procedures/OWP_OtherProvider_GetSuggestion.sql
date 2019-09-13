/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OtherProvider_GetSuggestion] @Keyword NVARCHAR(100)
AS	
/*
Created: 20190912@Leo
Task : Get suggestion
DB: bodb_OWP

 Revisions:
	20190912@Leo.Vo: Get suggestion - [Redmine: #119650]
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT TOP 10 OtherProviderId
		,OtherProviderName
	FROM dbo.[OtherProvider] WITH (NOLOCK)
	WHERE CHARINDEX(@Keyword, OtherProviderName) > 0
	ORDER BY CHARINDEX(@Keyword, OtherProviderName)
END