CREATE PROCEDURE [dbo].[OWP_LiveDetailGeneralInfoGet] @OWPMatchId INT
	,@UserId INT
AS
/*
Created: 2016-10-04@Aaron
Task : Get new Match Detail General Info
DB: bodb_OWP

Revisions:
    20170412@Tim.Trinh: check minor match
    20170420@Tim.Trinh: modify trader view time
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @EventDateTime DATETIME
		,@FromTime DATETIME
		,@ToTime DATETIME
		,@FromTimeForSpecialBettype DATETIME
		,@ToTimeViewDetailForSpecialBettype DATETIME
		,@ToTimeForSpecialBettype DATETIME
		,@LA_Section INT = 2
		,@LG_Section INT = 3
		,@IsAllowedToViewDetail BIT = 0

	CREATE TABLE #tblAssignedRoles (
		RoleId SMALLINT
		,SectionId SMALLINT
		,SectionName NVARCHAR(50)
		)

	SELECT @FromTime = FromTime
		,@ToTime = ToTime
		,@FromTimeForSpecialBettype = FromTimeForSpecialBettype
		,@ToTimeForSpecialBettype = ToTimeForSpecialBettype
		,@ToTimeViewDetailForSpecialBettype = ToTimeViewDetailForSpecialBettype
	FROM dbo.fnc_GetDateTimeForTraderViewTime()

	SELECT @EventDateTime = DATEADD(DAY, DATEDIFF(DAY, 0, EventDate), CAST(KickOffTime AS DATETIME))
	FROM dbo.OWPMatch WITH (NOLOCK)
	WHERE OWPMatchId = @OWPMatchId

	INSERT INTO #tblAssignedRoles (
		RoleId
		,SectionId
		,SectionName
		)
	SELECT ur.RoleId
		,u.SectionId
		,rr.Value
	FROM dbo.UserRole AS ur WITH (NOLOCK)
		INNER JOIN dbo.[User] AS u WITH (NOLOCK) ON u.UserId = ur.UserId
		INNER JOIN dbo.RefResource AS rr WITH (NOLOCK) ON rr.ResourceId = u.SectionId
	WHERE ur.UserId = @UserId
		AND rr.RefName = 'Section'

	IF @EventDateTime < @FromTime
	BEGIN
		SET @IsAllowedToViewDetail = 1
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM #tblAssignedRoles AS ar WITH (NOLOCK)
				WHERE ar.RoleId = 1
					AND (
						ar.SectionId = @LA_Section
						OR ar.SectionId = @LG_Section
						)
				)
		BEGIN
			IF (
					@EventDateTime BETWEEN @FromTime
						AND @ToTimeViewDetailForSpecialBettype
					)
			BEGIN
				SET @IsAllowedToViewDetail = 1
			END
			ELSE
			BEGIN
				SET @IsAllowedToViewDetail = 0
			END
		END
		ELSE
		BEGIN
			SET @IsAllowedToViewDetail = 1
		END
	END

	SELECT DISTINCT home.OWPTeamName AS HomeName
		,away.OWPTeamName AS AwayName
		,l.OWPLeagueName AS LeagueName
		,m.MatchNo
		,m.EventDate
		,(m.EventDate + m.KickOffTime) AS KickOffTime
		,(m.EventDate + m.OtherTime) AS OtherTime
		,(CASE 
			WHEN m.MatchId IS NOT NULL THEN 1
			ELSE 0 END
			) AS IsLinked
		,info.KOTimeRemark AS KickOffTimeRemark
		,(CASE 
			WHEN minor.MinorMatchId IS NULL THEN 0
			ELSE 1 END
			) AS IsMinorMatch
		,@IsAllowedToViewDetail AS IsAllowedToViewDetail
	FROM dbo.OWPMatch AS m WITH (NOLOCK)
		INNER JOIN dbo.MatchInfo AS info WITH (NOLOCK) ON m.OWPMatchId = info.OWPMatchId
		INNER JOIN dbo.OWPTeam AS home WITH (NOLOCK) ON home.OWPTeamId = m.OWPHomeId
		INNER JOIN dbo.OWPTeam AS away WITH (NOLOCK) ON away.OWPTeamId = m.OWPAwayId
		INNER JOIN dbo.OWPLeague AS l WITH (NOLOCK) ON l.OWPLeagueId = m.OWPLeagueId
		LEFT JOIN dbo.MinorMatch AS minor WITH (NOLOCK) ON m.OWPMatchId = minor.MinorMatchId
	WHERE m.OWPMatchId = @OWPMatchId

	DROP TABLE #tblAssignedRoles
END