
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetMaxbetCorner] @XML NVARCHAR(MAX)
AS

/*
Created: 20211203@Carlos.nguyen
Task : Get maxbet corner
DB: bodb_OWP

Revisions:
	20211203@Carlos.nguyen: Initial SP - [Redmine: #163362]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        CREATE TABLE #tblMaxbet
        (InfoSiteMatchId INT, 
         MaxBetFTHDP     MONEY
        );
        INSERT INTO #tblMaxbet
        (InfoSiteMatchId, 
         MaxBetFTHDP
        )
               SELECT [InfoSiteMatchId], 
                      [MaxBetFTHDP]
               FROM OPENXML(@idoc, '/Root/MaxBetOfFTHDP', 1) WITH([InfoSiteMatchId] INT, [MaxBetFTHDP] MONEY);
        EXEC sp_xml_removedocument 
             @idoc;
        SELECT m.InfoSiteMatchId, 
               sp.Maxbet_NextCorner AS MaxBetNextCorner, 
               sp.Maxbet_NoOfCorner AS MaxBetNoOfCorner
        FROM #tblMaxbet AS m
             INNER JOIN SpecialProduct AS sp ON m.MaxBetFTHDP = sp.Maxbet_FTHDP
                                                AND sp.[Type] = 'MBC';
        DROP TABLE #tblMaxbet;
    END;