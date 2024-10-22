
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetMaxbet] @OWPMatchId INT
                                           
AS

/*
Created: 20201207@Tyler.Dang
Task: Get maxbet
DB: bodb_OWP

Revisions:
	20201207@Tyler.Dang: Get maxbet - [Redmine: #145096]
	20210906@Luca.Duong: Remove cn88 - [Feature: #160666]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @HandicapHDP INT= 1, @OverUnderOU INT= 3, @1H_HandicapHDP INT= 7, @1H_OverUnder INT= 8;

        SELECT ms.Bettype AS 'BettypeId', ms.Maxbet AS 'Value'
        FROM MatchSetting AS ms WITH(NOLOCK)
        WHERE ms.Bettype IN(@HandicapHDP, @OverUnderOU, @1H_HandicapHDP, @1H_OverUnder)
        AND ms.OWPMatchId = @OwpMatchId;
    END;