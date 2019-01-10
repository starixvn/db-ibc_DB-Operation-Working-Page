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
	20190109@Raymond.Le: Rename Provider to Other Provider, Runner to Provider - [Redmine: #107257]
	20190110@Leo.Vo: Rename column RefResourceId in table RefResource - [Redmine: #107257]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @fieldLeagueId INT = 3
			,@LeagueIds NVARCHAR(MAX)
			,@fieldAssignee INT = 8
			,@AssigneeIds NVARCHAR(MAX)
			,@fieldTv INT = 9
			,@TVIds NVARCHAR(MAX)
			,@fieldOtherProvider INT = 13
			,@OtherProviderIds NVARCHAR(MAX)
			,@fieldProvider INT = 14
			,@ProviderIds NVARCHAR(MAX)
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

	CREATE TABLE #tblProvider (
		ProviderId INT
		,ProviderName NVARCHAR(100)
		,IsSelected BIT
	)
	
	CREATE TABLE #tblOtherProvider (
		OtherProviderId INT
		,OtherProviderName NVARCHAR(100)
		,IsSelected BIT
	)
	
	CREATE TABLE #tblRefResource (
		RefName NVARCHAR(30)
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

	--- Get Other Provider list
	SET @OtherProviderIds = (SELECT TOP 1 Value 
			FROM #tblFilterDetail
			WHERE FieldId = @fieldOtherProvider)

	IF @OtherProviderIds IS NOT NULL 
	BEGIN
		INSERT INTO #tblOtherProvider (
			OtherProviderId
			,OtherProviderName
			,IsSelected
		)
		SELECT	r.OtherProviderId
				,r.OtherProviderName
				,CASE WHEN pid.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.OtherProvider AS r WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@OtherProviderIds, ',') AS pid ON r.OtherProviderId = pid.val
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
		SELECT 	p.ProviderId
				,p.ProviderName
				,CASE WHEN rid.val IS NOT NULL THEN 1
					ELSE 0 END
		FROM dbo.[Provider] AS p WITH (NOLOCK)
			LEFT JOIN dbo.strSplit(@ProviderIds, ',') AS rid ON p.ProviderId = rid.val
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
			RefName
			,ResourceId
			,Value
			,IsSelected
		)
		SELECT  r.RefName
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
	
	SELECT 	ProviderId
			,ProviderName
			,IsSelected
	FROM #tblProvider
	
	SELECT 	OtherProviderId
			,OtherProviderName
			,IsSelected
	FROM #tblOtherProvider
	
	SELECT 	RefName
			,ResourceId
			,Value
			,IsSelected
	FROM #tblRefResource

	DROP TABLE #tblFilterDetail

	DROP TABLE #tblLeague

	DROP TABLE #tblUsers

    DROP TABLE #tblTelevision

	DROP TABLE #tblAgent
	
	DROP TABLE #tblProvider
	
	DROP TABLE #tblOtherProvider
	
	DROP TABLE #tblRefResource

	DROP TABLE #tblFilterInfo
END