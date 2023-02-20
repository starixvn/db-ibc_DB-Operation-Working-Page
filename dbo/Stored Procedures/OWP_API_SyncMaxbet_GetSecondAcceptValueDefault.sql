
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetSecondAcceptValueDefault] @OWPMatchId INT, 
                                                                       @MaxbetHDP  DECIMAL = NULL
AS

/*
Created: 20220901@Liam.pham
Task: Get second accept value default 
DB: bodb_OWP

Revisions:
	20220901@Liam.pham: Get second accept value default  - [Redmine: #176781]
	20230209@Mira: Get second accept value default  - [Redmine: #183242]
*/

    BEGIN
        DECLARE @maxbetHDPdefault INT= -1000;
        IF(NOT EXISTS
        (
            SELECT 1
            FROM MaxbetSetting mb
            WHERE mb.FT_HDP = @MaxbetHDP
        ))
            BEGIN
                SET @MaxbetHDP = @maxbetHDPdefault;
        END;
        SET NOCOUNT ON;

        -- select seccond accept value
        SELECT rrm.Value 'Main', 
               rrc.Value 'Corner', 
               rrt.Value 'TotalBooking', 
               rrf.Value 'Fantasy'
        FROM MaxbetSetting ms WITH(NOLOCK)
             LEFT JOIN dbo.RefResource AS rrm WITH(NOLOCK) ON ms.SecondAccept_Main = rrm.ResourceId
                                                              AND rrm.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrc WITH(NOLOCK) ON ms.SecondAccept_Corner = rrc.ResourceId
                                                              AND rrc.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrt WITH(NOLOCK) ON ms.SecondAccept_TotalBooking = rrt.ResourceId
                                                              AND rrt.RefName = 'MatchOffer'
             LEFT JOIN dbo.RefResource AS rrf WITH(NOLOCK) ON ms.SecondAccept_Fantasy = rrf.ResourceId
                                                              AND rrf.RefName = 'MatchOffer'
        WHERE ms.FT_HDP = @MaxbetHDP;

        -- select league name
        SELECT l.OWPLeagueName
        FROM OWPMatch o
             INNER JOIN OWPLeague l ON o.OWPLeagueId = l.OWPLeagueId
        WHERE o.OWPMatchId = @OWPMatchId;
    END;