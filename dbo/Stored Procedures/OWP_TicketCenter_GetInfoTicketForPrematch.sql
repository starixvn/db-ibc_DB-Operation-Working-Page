
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TicketCenter_GetInfoTicketForPrematch] @TicketId       INT, 
                                                                   @IsTicketLeague BIT
AS

/*
Created: 20230609@Mira
Task : Refactor pre match
DB: bodb_OWP

Revisions:
	20230609@Mira: Refactor pre match - [Redmine: #188625]
	20230807@Los: Get ticket event - [Redmine: #191778]
*/

    BEGIN
        SET NOCOUNT ON;

        -- select Id
        IF(@IsTicketLeague = 1)
            BEGIN
                SELECT OwpLeagueId_New AS OwpLeagueId
                FROM dbo.TicketIssue WITH(NOLOCK)
                WHERE TicketId = @TicketId;
        END;
            ELSE
            BEGIN
                SELECT InfoSiteMatchId_New AS InfoSiteMatchId
                FROM dbo.TicketIssue WITH(NOLOCK)
                WHERE TicketId = @TicketId;
        END;
    END;