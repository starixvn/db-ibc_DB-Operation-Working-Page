
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMaxbet] @OWPMatchId INT, 
                                                              @IsCN88     BIT
AS

/*
Created: 20201207@Tyler.Dang
Task: Get maxbet
DB: bodb_OWP

Revisions:
	20201207@Tyler.Dang: Get maxbet - [Redmine: #145096]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @HandicapHDP INT= 1, @OverUnderOU INT= 3, @1H_HandicapHDP INT= 7, @1H_OverUnder INT= 8;

        SELECT ms.Bettype AS 'BettypeId',
               CASE
                   WHEN @IsCN88 = 0
                   THEN ms.Maxbet
                   ELSE ms.MaxbetCN88
               END AS 'Value'
        FROM MatchSetting AS ms WITH(NOLOCK)
        WHERE ms.Bettype IN(@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder)
        AND ms.OWPMatchId = @OwpMatchId;
    END;