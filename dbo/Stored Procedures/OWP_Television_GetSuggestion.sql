/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Television_GetSuggestion] @Keyword NVARCHAR(100)
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
	
	SELECT TOP 10 TVId
		,TVCode
		,Color
	FROM dbo.Television WITH (NOLOCK)
	WHERE CHARINDEX(@Keyword, TVCode) > 0
	ORDER BY CHARINDEX(@Keyword, TVCode), TVCode
END