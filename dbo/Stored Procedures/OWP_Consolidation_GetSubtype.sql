
ALTER PROCEDURE dbo.[OWP_Consolidation_GetSubtype] @ActorId INT

/*
Created: 20240814@Los
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20240814@Los: Get subtype - [Redmine: #207945]
*/

AS
    BEGIN
        SET NOCOUNT ON;

        /**/

        DECLARE @FromDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, 2, GETDATE()), '12:00:00'), @ToDateTime DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), '11:59:59');
        DECLARE @tplSubtype TABLE
        (TypeId          INT NOT NULL, 
         SubtypeId       INT, 
         SubtypeName     NVARCHAR(2000), 
         IsRead          BIT, 
         LastCommentDate DATETIME
        );
        INSERT INTO @tplSubtype
        (TypeId, 
         SubtypeId, 
         SubtypeName, 
         IsRead, 
         LastCommentDate
        )
               SELECT tt.TypeId, 
                      ts.SubtypeId, 
                      (tt.TypeName + ' - ' + ISNULL(ts.SubtypeName, 'None')) 'SubtypeName', 
                      tmr.IsRead, 
                      tis.LastCommentDate
               FROM TicketIssue AS tis WITH(NOLOCK)
                    INNER JOIN TicketMessageReader AS tmr WITH(NOLOCK) ON tis.TicketId = tmr.TicketId
                    INNER JOIN TicketType AS tt WITH(NOLOCK) ON tt.TypeId = tis.TicketType
                    LEFT JOIN TicketSubtype AS ts WITH(NOLOCK) ON tis.SubtypeId = ts.SubtypeId
               WHERE tmr.RecipientId = @ActorId
                     AND tis.LastCommentDate BETWEEN @FromDateTime AND @ToDateTime
               ORDER BY tis.LastCommentDate;
        SELECT DISTINCT 
               TypeId, 
               SubtypeId, 
               SubtypeName, 
               IsRead
        FROM @tplSubtype;
    END;