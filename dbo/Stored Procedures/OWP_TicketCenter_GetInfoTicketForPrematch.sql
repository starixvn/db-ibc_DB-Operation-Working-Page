
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetInfoTicketForPrematch] @TicketId       INT, 
                                                                   @IsTicketLeague BIT
AS

/*
Created: 20230609@Mira
Task : Refactor pre match
DB: bodb_OWP

Revisions:
	20230609@Mira: Refactor pre match - [Redmine: #188625]
*/

    BEGIN
        SET NOCOUNT ON;

        -- select Id
        IF(@IsTicketLeague = 1)
            BEGIN
                SELECT OwpLeagueId
                FROM dbo.TicketIssueLeague WITH(NOLOCK)
                WHERE TicketId = @TicketId;
        END;
            ELSE
            BEGIN
                SELECT InfoSiteMatchId
                FROM dbo.TicketIssueEvent WITH(NOLOCK)
                WHERE TicketId = @TicketId;
        END;
    END;