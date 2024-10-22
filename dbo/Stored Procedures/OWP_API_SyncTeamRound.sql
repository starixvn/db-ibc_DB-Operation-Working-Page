/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncTeamRound] @Xml NVARCHAR(MAX)
AS
/*
Created: 20231026@los
Task : Sync round
DB: bodb_OWP

Revisions:
	20231026@los: sync round - [Redmine: #193810]
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @idoc INT


	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@Xml

	CREATE TABLE #tblInfoSiteMatch (
		[InfoSiteMatchId] INT 
		,[TeamRound] NVARCHAR(2000)
		)

	INSERT INTO #tblInfoSiteMatch (
		 [InfoSiteMatchId]
		,[TeamRound]
		)
	SELECT [InfoSiteMatchId]
	    ,[TeamRound]
	FROM OPENXML(@idoc, '/Root/TeamRoundInfo', 1) WITH (
			 [InfoSiteMatchId] [int]
			,[TeamRound] [nvarchar](2000)
			)

	EXEC sp_xml_removedocument @idoc


	UPDATE l
	SET l.TeamRound = im.TeamRound
	FROM dbo.InfoSiteMatch AS l WITH (NOLOCK) INNER JOIN #tblInfoSiteMatch AS im
	ON im.InfoSiteMatchId = l.InfoSiteMatchId
	
	DROP TABLE #tblInfoSiteMatch
END

