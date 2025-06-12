/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketEvent_GetTicketByOwpMatchId] @OwpMatchId INT,
																@ActorId INT
AS

/*      
 Created: 20220216@Carlos.nguyen
 Task : Get ticket
 DB: bodb_OWP      
      
 Revisions:          
	20220929@Carlos.nguyen: Init sp - [Redmine: #178183]
	20230807@Los: Get ticket event - [Redmine: #191778]
	20240222@Johnny : Get ticket relative - [Redmine: #200265]
	20250408@Lilac : Get home, away - [Redmine: #221727]
    20250612@Frankie : Create rocket chat discussion - [Feature: #229399]
*/

    BEGIN
        SET NOCOUNT ON;
		CREATE TABLE #tblOwpMatch (OWPMatchId INT);

        INSERT INTO #tblOwpMatch(OWPMatchId)
        VALUES(@OwpMatchId);
        INSERT INTO #tblOwpMatch(OWPMatchId)
               SELECT mm.ParentMatchId
               FROM MinorMatch AS mm WITH(NOLOCK)
               WHERE mm.MinorMatchId = @OwpMatchId;
        INSERT INTO #tblOwpMatch(OWPMatchId)
               SELECT mm.MinorMatchId
               FROM MinorMatch AS mm WITH(NOLOCK)
                    INNER JOIN #tblOwpMatch AS r ON mm.ParentMatchId = r.OWPMatchId;

		-- select Latest comment ticket
        SELECT DISTINCT
               x.TicketId,
               CASE
                   WHEN u.Nickname IS NULL
                   THEN u.Username
                   ELSE u.Nickname
               END AS LatestUsername, 
               tm.CreatedDate AS LatestCreatedDate,
               m.EventDateTime AS EventDate,
               tm.[Message] AS LatestMessage, 
               reader.IsRead, 
               ts.SubtypeId, 
               ts.SubtypeName,
			   x.OWPMatchId,
				(CASE
					WHEN m.IsNeutral = 1
					THEN h.OWPTeamName + ' (N)'
					ELSE h.OWPTeamName
				 END) AS Home, 
				a.OWPTeamName AS Away,
				x.CreatedDate,
				0 AS IsRC,
				'' AS DiscussionName,
				'' AS ChannelRC
        FROM
        (
            SELECT ti.TicketId, 
                   MAX(tm.Id) MaxId, 
                   ti.SubtypeId,
				   ti.CreatedDate,
				   owpm.OWPMatchId
            FROM #tblOwpMatch AS owpm 
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON owpm.OWPMatchId=ti.OwpMatchId_New
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
				 
			WHERE ti.EventType_New=5
				AND (ti.IsRC IS NULL OR ti.IsRC = 0)
            GROUP BY ti.TicketId, 
                     ti.SubtypeId,
					 ti.CreatedDate,
					 owpm.OWPMatchId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
		LEFT JOIN dbo.OWPMatch AS m WITH(NOLOCK) ON m.OWPMatchId = x.OWPMatchId
		LEFT JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		LEFT JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId
        WHERE tm.Id = x.MaxId

		UNION 

		SELECT DISTINCT
               x.TicketId,
               '' AS LatestUsername, 
               NULL AS LatestCreatedDate,
               m.EventDateTime AS EventDate,
               '' AS LatestMessage, 
               1 AS IsRead, 
               0 AS SubtypeId, 
               '' AS SubtypeName,
			   x.OWPMatchId,
				(CASE
					WHEN m.IsNeutral = 1
					THEN h.OWPTeamName + ' (N)'
					ELSE h.OWPTeamName
				 END) AS Home, 
				a.OWPTeamName AS Away,
				x.CreatedDate,
				1 AS IsRC,
				x.DiscussionName AS DiscussionName,
				x.ChannelRC AS ChannelRC
        FROM
        (
            SELECT ti.TicketId,
				   owpm.OWPMatchId,
				   ti.CreatedDate,
				   ti.DiscussionName,
				   ti.ChannelRC
            FROM #tblOwpMatch AS owpm 
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON owpm.OWPMatchId=ti.OwpMatchId_New
			WHERE ti.IsRC = 1
        ) AS x
		LEFT JOIN dbo.OWPMatch AS m WITH(NOLOCK) ON m.OWPMatchId = x.OWPMatchId
		LEFT JOIN dbo.OWPTeam AS h WITH(NOLOCK) ON m.OWPHomeId = h.OWPTeamId
		LEFT JOIN dbo.OWPTeam AS a WITH(NOLOCK) ON m.OWPAwayId = a.OWPTeamId

		ORDER BY IsRC DESC,CreatedDate DESC, tm.CreatedDate DESC
    END;