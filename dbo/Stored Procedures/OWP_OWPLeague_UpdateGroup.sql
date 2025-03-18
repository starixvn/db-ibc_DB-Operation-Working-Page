/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_OWPLeague_UpdateGroup]  @ActorId INT
	,@OWPLeagueId INT
	,@LeagueGroupId INT
AS
/*  
Created: 20200407@Tyler.Dang  
Task : Update league group
DB: bodb_OWP  
  
Revisions:
	20200407@Tyler.Dang: Init - [Redmine: #131923]   
	20250317@Frankie: enable change league group - [Redmine: #219096]   
*/
BEGIN
	SET NOCOUNT ON;

	-- Select the most recent history record for the given OWPLeagueId
    SELECT TOP 1
        Id,
        OWPLeagueId,
        CategoryId,
        StartDate,
        EndDate
    INTO #lastHistory
    FROM [dbo].[LeagueCategoryHistory] WITH(NOLOCK)
    WHERE OWPLeagueId = @OWPLeagueId
    ORDER BY StartDate DESC;

    -- Get the current date
    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    -- Case 1: No existing history record found
    IF NOT EXISTS (SELECT 1 FROM #lastHistory)
    BEGIN
        -- Insert a new history record with the current date as StartDate
        INSERT INTO [dbo].[LeagueCategoryHistory] (OWPLeagueId, CategoryId, StartDate, EndDate)
        VALUES (@OWPLeagueId, @LeagueGroupId, @today, NULL);
    END;
    ELSE
    BEGIN
        -- Case 2: Existing history record found with StartDate < today
        IF (SELECT StartDate FROM #lastHistory) < @today
        BEGIN
            -- Update the EndDate of the existing record to yesterday
            UPDATE [dbo].[LeagueCategoryHistory] WITH (UPDLOCK, ROWLOCK)
            SET EndDate = DATEADD(day, -1, @today)
            WHERE Id = (SELECT Id FROM #lastHistory);

            -- Insert a new history record with the current date as StartDate
            INSERT INTO [dbo].[LeagueCategoryHistory] (OWPLeagueId, CategoryId, StartDate, EndDate)
            VALUES (@OWPLeagueId, @LeagueGroupId, @today, NULL);
        END;
        ELSE
        BEGIN
            -- Case 3: Existing history record found with StartDate = today
            -- Update the CategoryId of the existing record
            UPDATE [dbo].[LeagueCategoryHistory] WITH (UPDLOCK, ROWLOCK)
            SET CategoryId = @LeagueGroupId
            WHERE Id = (SELECT Id FROM #lastHistory);
        END;
    END;

    -- Drop the temporary table
    DROP TABLE #lastHistory;
END