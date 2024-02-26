
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

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
*/

    BEGIN
        SET NOCOUNT ON;
		CREATE TABLE #tblOwpMatch (OWPMatchId INT);

        INSERT INTO #tblOwpMatch(OWPMatchId)
        VALUES(@OwpMatchId);
        INSERT INTO #tblOwpMatch(OWPMatchId)
               SELECT mm.ParentMatchId
               FROM MinorMatch AS mm
               WHERE mm.MinorMatchId = @OwpMatchId;
        INSERT INTO #tblOwpMatch(OWPMatchId)
               SELECT mm.MinorMatchId
               FROM MinorMatch AS mm
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
               tm.[Message] AS LatestMessage, 
               reader.IsRead, 
               ts.SubtypeId, 
               ts.SubtypeName,
			   x.OWPMatchId
        FROM
        (
            SELECT ti.TicketId, 
                   MAX(tm.Id) MaxId, 
                   ti.SubtypeId,
				   owpm.OWPMatchId
            FROM #tblOwpMatch AS owpm 
                 INNER JOIN dbo.TicketIssue ti WITH(NOLOCK) ON owpm.OWPMatchId=ti.OwpMatchId_New
                 LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON ti.TicketId = tm.TicketId
			WHERE ti.EventType_New=5
            GROUP BY ti.TicketId, 
                     ti.SubtypeId,
					 owpm.OWPMatchId
        ) AS x
        LEFT JOIN dbo.TicketMessage AS tm WITH(NOLOCK) ON tm.TicketId = x.TicketId
        INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON tm.UserId = u.UserId
        INNER JOIN dbo.TicketMessageReader AS reader WITH(NOLOCK) ON x.TicketId = reader.TicketId
                                                                     AND reader.RecipientId = @ActorId
        LEFT JOIN dbo.TicketSubtype AS ts WITH(NOLOCK) ON ts.SubtypeId = x.SubtypeId
        WHERE tm.Id = x.MaxId
		ORDER BY tm.CreatedDate DESC
    END;