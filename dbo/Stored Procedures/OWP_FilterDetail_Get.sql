/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_FilterDetail_Get] @FilterId INT = 0
AS
/*      
 Created: 20171207@Raymond.Le
 Task : 
 DB: bodb_OWP      
      
 Revisions:          
	20180927@Leo: New structure of event assignment - [Redmine: #92868]
	20181026@Raymond.Le: Enhance performance page Live Game List - [Redmine: #103598]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @fieldLeagueId INT = 3
			,@LeagueIds NVARCHAR(MAX)
			,@fieldAssignee INT = 8
			,@AssigneeIds NVARCHAR(MAX)
			,@fieldTv INT = 9
			,@TVIds NVARCHAR(MAX)
			,@fieldProvider INT = 13
			,@ProviderIds NVARCHAR(MAX)
			,@fieldRunner INT = 14
			,@RunnerIds NVARCHAR(MAX)
			,@fieldAgent INT = 12
			,@AgentIds NVARCHAR(MAX)
			,@fieldMatchStatus INT = 20
			,@MatchStatusIds NVARCHAR(MAX)

	CREATE TABLE #tblFilterInfo (
		FilterId INT
		,Name NVARCHAR(100)
		,IsPublic BIT
	)	
		
	CREATE TABLE #tblFilterDetail (
		FieldId INT
		,Operator INT
		,Value NVARCHAR(4000)
	)

	CREATE TABLE #tblLeague (
		LeagueId INT
		,[Name] NVARCHAR(500)
		)

	CREATE TABLE #tblUsers (
		UserId INT
		,Username NVARCHAR(150)
		)

	CREATE TABLE #tblTelevision (
		TVId INT
		,TVCode NVARCHAR(100)
		,IsSelected BIT
	)
	
	CREATE TABLE #tblAgent (
		AgentId INT
		,AgentName NVARCHAR(100)
		,IsSelected BIT
	)

	CREATE TABLE #tblRunner (
		RunnerId INT
		,RunnerName NVARCHAR(100)
		,IsSelected BIT
	)
	
	CREATE TABLE #tblProvider (
		ProviderId INT
		,ProviderName NVARCHAR(100)
		,IsSelected BIT
	)
	
	CREATE TABLE #tblRefResource (
		RefResourceId INT
		,RefName NVARCHAR(30)
		,ResourceId INT
		,Value NVARCHAR(200)
		,IsSelected BIT
	)

	----
	INSERT INTO #tblFilterInfo (
		FilterId
		,Name
		,IsPublic
	)
	SELECT ft.FilterId
			,ft.FilterName
			,ft.IsPublic
	FROM dbo.Filter AS ft WITH (NOLOCK)
	WHERE ft.FilterId = @FilterId


	INSERT INTO #tblFilterDetail (
		FieldId
		,Operator
		,Value
	)
	SELECT fd.FieldId
		,fd.Operator
		,fd.Value
	FROM dbo.FilterDetail AS fd WITH (NOLOCK)
	WHERE fd.FilterId = @FilterId

	---- Hardcode insert field EventDate. (In future, if it has more required field, add column 'DefaultValue' to table FilterDetail to get default value)
	IF NOT EXISTS (SELECT 1 
					FROM #tblFilterDetail
					WHERE FieldId = 1)
	BEGIN
		INSERT INTO #tblFilterDetail (
			FieldId
			,Operator
			,Value
		) VALUES (1, 0, '0')		
	END

	--- Get League list
	SET @LeagueIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldLeagueId)

	IF @LeagueIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblLeague (
			LeagueId
			,[Name]
			)
		SELECT league.OWPLeagueId
			,league.OWPLeagueName
		FROM dbo.strSplit(@LeagueIds, ',') AS lid
			INNER JOIN dbo.OWPLeague AS league WITH (NOLOCK) ON CAST(lid.[val] AS INT) = league.OWPLeagueId
	END

	--- Get Assignee list
	SET @AssigneeIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldAssignee)

	IF @AssigneeIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblUsers (
			UserId
			,Username
			)
		SELECT u.UserId
			,u.Username
		FROM dbo.strSplit(@AssigneeIds, ',') AS userid
			INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON CAST(userid.[val] AS INT) = u.UserId
	END

	--- Get Tv list
	SET @TVIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldTv)

	IF @TVIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblTelevision (
			TVId
			,TVCode
			,IsSelected
		)
		SELECT	t.TVId 
				,t.TVCode
				,CASE WHEN tvc.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.Television AS t WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@TVIds, ',') AS tvc ON t.TVId = tvc.val
	END

	--- Get Provider list
	SET @ProviderIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldProvider)

	IF @ProviderIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblProvider (
			ProviderId
			,ProviderName
			,IsSelected
		)
		SELECT	r.ProviderId
				,r.ProviderName
				,CASE WHEN pid.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.Provider AS r WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@ProviderIds, ',') AS pid ON r.ProviderId = pid.val
	END

	--- Get Runner list
	SET @RunnerIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldRunner)

	IF @RunnerIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblRunner (
			RunnerId
			,RunnerName
			,IsSelected
		)
		SELECT 	r.RunnerId
				,r.RunnerName
				,CASE WHEN rid.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.Runner AS r WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@RunnerIds, ',') AS rid ON r.RunnerId = rid.val
	END

	--- Get Agent list
	SET @AgentIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldAgent)

	IF @AgentIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblAgent(
			AgentId
			,AgentName
			,IsSelected
		)
		SELECT 	r.AgentId
				,r.AgentName
				,CASE WHEN aid.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.Agent AS r WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@AgentIds, ',') AS aid ON r.AgentId = aid.val
	END

	--- Get Match status list
	SET @MatchStatusIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldMatchStatus)

	IF @MatchStatusIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblRefResource (
			RefResourceId
			,RefName
			,ResourceId
			,Value
			,IsSelected
		)
		SELECT  r.RefResourceId
				,r.RefName
				,r.ResourceId
				,r.Value
				,CASE WHEN msi.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.RefResource AS r WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@MatchStatusIds, ',') AS msi ON r.ResourceId = msi.val
		WHERE r.RefName = 'MatchStatus' 
	END

	---- Return data
	SELECT
		FilterId
		,Name
		,IsPublic
	FROM #tblFilterInfo

	SELECT 	
		FieldId
		,Operator
		,Value
	FROM #tblFilterDetail
	ORDER BY FieldId

	SELECT ff.FieldId
		,ff.Name
		,ff.[Text]
		,ff.IsRequired
		,(CASE WHEN fd.FieldId IS NULL THEN 0
			ELSE 1 END) AS IsHasValue
	FROM dbo.FilterField AS ff WITH (NOLOCK)
		LEFT JOIN (SELECT DISTINCT FieldId
					FROM #tblFilterDetail) AS fd ON ff.FieldId = fd.FieldId
	WHERE ff.Name <> 'IsSelected'
		

	SELECT LeagueId
		,[Name]
	FROM #tblLeague

	SELECT UserId
		,Username
	FROM #tblUsers

	SELECT 	TVId
			,TVCode
			,IsSelected
	FROM #tblTelevision

	SELECT 	AgentId
			,AgentName
			,IsSelected
	FROM #tblAgent
	
	SELECT 	RunnerId
			,RunnerName
			,IsSelected
	FROM #tblRunner
	
	SELECT 	ProviderId
			,ProviderName
			,IsSelected
	FROM #tblProvider
	
	SELECT 	RefResourceId
			,RefName
			,ResourceId
			,Value
			,IsSelected
	FROM #tblRefResource

	DROP TABLE #tblFilterDetail

	DROP TABLE #tblLeague

	DROP TABLE #tblUsers

    DROP TABLE #tblTelevision

	DROP TABLE #tblAgent
	
	DROP TABLE #tblRunner
	
	DROP TABLE #tblProvider
	
	DROP TABLE #tblRefResource

	DROP TABLE #tblFilterInfo
END