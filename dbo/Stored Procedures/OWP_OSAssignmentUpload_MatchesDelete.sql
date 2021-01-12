
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_OSAssignmentUpload_MatchesDelete] @MatchIds NVARCHAR(MAX)
AS

/*
Created: 20201224@Mira
Task : Other Sport Uploading
DB: bodb_OWP

Revisions:
	20201224@Mira: Init SP - [Redmine: #146962]	
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tempMatch TABLE(MatchId INT);
        INSERT INTO @tempMatch
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@MatchIds, ',') u OPTION(MAXRECURSION 0);

        -- Match			
        DELETE m
        FROM dbo.OSMatch m
             INNER JOIN @tempMatch t ON m.OSMatchId = t.MatchId;

        -- Match Assignment
        DELETE m
        FROM dbo.OSAssignment m
             INNER JOIN @tempMatch t ON m.OSMatchId = t.MatchId;

        -- MaxBet
        DELETE m
        FROM dbo.OSMaxBet m
             INNER JOIN @tempMatch t ON m.OSMatchId = t.MatchId;
    END;