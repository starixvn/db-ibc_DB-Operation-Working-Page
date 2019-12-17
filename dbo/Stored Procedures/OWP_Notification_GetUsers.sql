/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_Notification_GetUsers] @OWPMatchId INT
	,@AssigneeSettingId INT
	,@WatcherSettingId INT
AS
/*          
 Created: 20191106@Leo.Vo
 Task : Get users to send notification
 DB: bodb_OWP          
          
 Revisions:
	20191106@Leo.Vo: Init SP - [Redmine: #116230]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblAssignee TVP_INT
		,@tblWatcher TVP_INT
		
	CREATE TABLE #tblAllAssignee (
		UserId INT NOT NULL
	)
	
	CREATE TABLE #tblSectionMemberOfUserReceivedWatcher (
		MemberId INT
		,UserReceivedWatcherId INT
	)
	
	IF dbo.[fnc_IsMatchInTimeRange](@OWPMatchId) = 1
	BEGIN
		-- get all assignee in match (include main + minor)
		INSERT INTO #tblAllAssignee (UserId)
		SELECT UserId
		FROM dbo.fnc_GetAllAssigneeOfMatch(@OWPMatchId)
		
		-- get list users received ASSIGNEE message update Recommend Odds
		INSERT INTO @tblAssignee (Id)
		SELECT a.UserId
		FROM #tblAllAssignee AS a
			LEFT JOIN dbo.NotificationSetting AS ns WITH (NOLOCK) ON ns.NotificationSettingId = @AssigneeSettingId
			LEFT JOIN dbo.NotificationSettingMapping AS nsm WITH (NOLOCK) ON ns.NotificationSettingId = nsm.NotificationSettingId
			AND nsm.UserId = a.UserId
		WHERE ISNULL(nsm.Value, ns.DefaultValue) = 'True'
		
		-- get all SectionMemberOfUserReceivedWatcher
		INSERT INTO #tblSectionMemberOfUserReceivedWatcher (
			MemberId
			,UserReceivedWatcherId
			)
		SELECT ISNULL(mem.UserId, r.UserId)
			,r.UserId
		FROM (
			SELECT w.UserId
				,u.SectionId
			FROM dbo.fnc_GetWatcherToSendMessage(@WatcherSettingId) AS w
				LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON w.UserId = u.UserId
			) AS r
			LEFT JOIN dbo.[User] AS mem WITH (NOLOCK) ON r.SectionId = mem.SectionId
			AND mem.SectionId IS NOT NULL
			
		-- get list users received Watcher message update Recommend Odds
		INSERT INTO @tblWatcher (Id)
		SELECT DISTINCT sm.UserReceivedWatcherId
		FROM #tblAllAssignee AS a
			INNER JOIN #tblSectionMemberOfUserReceivedWatcher AS sm ON sm.MemberId = a.UserId
		WHERE NOT EXISTS (
			-- ignore user received Assignee message
			SELECT 1
			FROM @tblAssignee AS ur
			WHERE ur.Id = sm.UserReceivedWatcherId
		)
	END
	
	SELECT Id AS UserId
	FROM @tblAssignee
	
	SELECT Id AS UserId
	FROM @tblWatcher
	
	DROP TABLE #tblAllAssignee
	
	DROP TABLE #tblSectionMemberOfUserReceivedWatcher
END