
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TVSSupport_GetProviderByMatchId] @MatchId INT
AS

/*    
 Created: 20220613@Mira
 Task: Provide Provider info to TVS
 DB: bodb_OWP    
    
 Revisions:
	20220613@Mira: Get provider by matchid - [Redmine: #173991]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT TOP (1) m.MatchId, 
                       p.ProviderName
        FROM dbo.OWPMatch m WITH(NOLOCK)
             LEFT JOIN dbo.MatchProvider mp WITH(NOLOCK) ON m.OWPMatchId = mp.OWPMatchId
             LEFT JOIN dbo.Provider p WITH(NOLOCK) ON p.ProviderId = mp.ProviderId
        WHERE m.MatchId = @MatchId
        ORDER BY m.EventDateTime DESC;
    END;