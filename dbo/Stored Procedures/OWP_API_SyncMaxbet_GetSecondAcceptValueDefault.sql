

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncMaxbet_GetSecondAcceptValueDefault] @OWPMatchId INT, 
                                                     @MaxbetHDP  DECIMAL = -1000 
AS

/*
Created: 20220901@Liam.pham
Task: Get second accept value default 
DB: bodb_OWP

Revisions:
	20220901@Liam.pham: Get second accept value default  - [Redmine: #176781]

*/

    BEGIN  
        SET NOCOUNT ON;
        SELECT ms.SecondAccept_Main 'Main', 
               ms.SecondAccept_Corner 'Corner', 
               ms.SecondAccept_TotalBooking 'TotalBooking', 
               ms.SecondAccept_Fantasy 'Fantasy'
        FROM MaxbetSetting ms
		Where ms.FT_HDP = @MaxbetHDP ;

        SELECT l.OWPLeagueName
        FROM OWPMatch o
             INNER JOIN OWPLeague l ON o.OWPLeagueId = l.OWPLeagueId
        WHERE o.OWPMatchId = @OWPMatchId;
    END;



