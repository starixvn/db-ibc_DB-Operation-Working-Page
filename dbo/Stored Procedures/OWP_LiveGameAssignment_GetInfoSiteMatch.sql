
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_LiveGameAssignment_GetInfoSiteMatch] @InfoSiteMatchId INT
AS
/*
Created: 20190725@Tyler.Dang
Task : Get InfoSiteMatch on Add new event
DB: bodb_OWP

Revisions:
	20190725@Tyler.Dang: Initial SP - [Redmine: #117578]
*/
BEGIN
	SET NOCOUNT ON

	SELECT CAST(EventDateTime AS TIME) [KOTime]
		,LeagueName
		,HomeName
		,AwayName
		,[Round]
		,Division
		,AgentIds
		,TVIds
		,WB
		,Channel
		,Website1
		,Website2
		,Website3
		,Website4
	FROM dbo.[InfoSiteMatch] WITH (NOLOCK)
	WHERE InfoSiteMatchId = @InfoSiteMatchId
END