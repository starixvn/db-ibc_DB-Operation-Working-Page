/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_OSAssignmentUpload_MatchesDelete] @MatchIds NVARCHAR(MAX)
AS
/*
Created: 20201224@Mira
Task : Other Sport Uploading
DB: bodb_OWP

Revisions:
	20201224@Mira: Init SP - [Redmine: #146962]
    20241203@Tim: prevent locking, use built-in func
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @tempMatch TABLE(MatchId INT);

    INSERT INTO @tempMatch
    SELECT DISTINCT value
    FROM STRING_SPLIT(@MatchIds, ',')

    -- Match			
    DELETE m
    FROM dbo.OSMatch AS m WITH (ROWLOCK)
        INNER JOIN @tempMatch AS t ON m.OSMatchId = t.MatchId;

    -- Match Assignment
    DELETE m
    FROM dbo.OSAssignment AS m WITH (ROWLOCK)
        INNER JOIN @tempMatch AS t ON m.OSMatchId = t.MatchId;

    -- MaxBet
    DELETE m
    FROM dbo.OSMaxBet AS m WITH (ROWLOCK)
        INNER JOIN @tempMatch AS t ON m.OSMatchId = t.MatchId;
END;