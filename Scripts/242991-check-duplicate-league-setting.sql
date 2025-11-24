
/*fullconfition info like this
{"HasTv":false,"HasIpTv":false,"IpTv":null,"Round":[{"Type":"Contains","Value":"Final"},{"Type":"Equals","Value":"Final"},{"Type":"Contains","Value":"Final"},{"Type":"Contains","Value":"Final"}],"Division":[],"Remark":""}*/

/* get all league setting with duplicate condition except remark data*/

USE [bodb_OWP]
GO
-- Create temp table to store parsed JSON data
CREATE TABLE #ParsedLeagueSettings (
    LeagueSettingId INT,
    OWPLeagueId INT,
    LeagueName NVARCHAR(500),
    FullConditionDescription NVARCHAR(MAX),
    HasTv NVARCHAR(10),
    HasIpTv NVARCHAR(10),
    IpTv NVARCHAR(500),
    Remark NVARCHAR(500),
    Round_Type NVARCHAR(50),
    Round_Value NVARCHAR(200),
    Round_Index INT,
    Division_Type NVARCHAR(50),
    Division_Value NVARCHAR(200),
    Division_Index INT
);

-- Insert parsed data into temp table
INSERT INTO #ParsedLeagueSettings
SELECT
    l.Id as LeagueSettingId,
    l.OWPLeagueId,
    o.OWPLeagueName as LeagueName,
    l.FullConditionDescription,
    -- Extract basic JSON properties
    JSON_VALUE(l.FullConditionDescription, '$.HasTv') as HasTv,
    JSON_VALUE(l.FullConditionDescription, '$.HasIpTv') as HasIpTv,
    JSON_VALUE(l.FullConditionDescription, '$.IpTv') as IpTv,
    JSON_VALUE(l.FullConditionDescription, '$.Remark') as Remark,

    -- Parse Round array items
    ROUND_ITEM.[Type] as Round_Type,
    ROUND_ITEM.[Value] as Round_Value,
    ROUND_ITEM.[key] as Round_Index,

    -- Parse Division array items (same format as Round)
    DIV_ITEM.[Type] as Division_Type,
    DIV_ITEM.[Value] as Division_Value,
    DIV_ITEM.[key] as Division_Index
FROM LeagueManagementSetting l WITH(NOLOCK)
INNER JOIN OWPLeague o WITH(NOLOCK) ON l.OWPLeagueId = o.OWPLeagueId
OUTER APPLY OPENJSON(l.FullConditionDescription, '$.Round') WITH (
    [Type] NVARCHAR(50),
    [Value] NVARCHAR(200),
    [key] INT
) AS ROUND_ITEM
OUTER APPLY OPENJSON(l.FullConditionDescription, '$.Division') WITH (
    [Type] NVARCHAR(50),
    [Value] NVARCHAR(200),
    [key] INT
) AS DIV_ITEM
WHERE l.FullConditionDescription IS NOT NULL
    AND l.FullConditionDescription != ''
    AND ISJSON(l.FullConditionDescription) = 1;

-- Create temp table for duplicate check
CREATE TABLE #DuplicateCheck (
    LeagueSettingId INT,
    OWPLeagueId INT,
    LeagueName NVARCHAR(500),
    ConditionKey NVARCHAR(MAX),
    FullConditionDescription NVARCHAR(MAX),
    HasTv NVARCHAR(10),
    HasIpTv NVARCHAR(10),
    IpTv NVARCHAR(500),
    Remark NVARCHAR(500),
    Round_Type NVARCHAR(50),
    Round_Value NVARCHAR(200),
    Round_Index INT,
    Division_Type NVARCHAR(50),
    Division_Value NVARCHAR(200),
    Division_Index INT
);

-- Insert data into DuplicateCheck temp table
INSERT INTO #DuplicateCheck
SELECT
    LeagueSettingId,
    OWPLeagueId,
    LeagueName,
    -- Create a hash key from condition elements including leagueId (excluding remarks and betting settings)
    CONCAT(
        CAST(OWPLeagueId AS NVARCHAR(20)),
        '|', ISNULL(HasTv, ''),
        '|', ISNULL(HasIpTv, ''),
        '|', ISNULL(IpTv, ''),
        '|', ISNULL(Round_Type + ':' + Round_Value, ''),
        '|', ISNULL(Division_Type + ':' + Division_Value, '')
    ) as ConditionKey,
    FullConditionDescription,
    HasTv, HasIpTv, IpTv, Remark,
    Round_Type, Round_Value, Round_Index,
    Division_Type, Division_Value, Division_Index
FROM #ParsedLeagueSettings;

-- Create temp table for duplicate groups
CREATE TABLE #DuplicateGroups (
    ConditionKey NVARCHAR(MAX),
    DuplicateCount INT,
    SettingIds NVARCHAR(MAX),
    LeagueNames NVARCHAR(MAX),
    LeagueIds NVARCHAR(MAX)
);

-- Insert data into DuplicateGroups temp table
INSERT INTO #DuplicateGroups
SELECT
    ConditionKey,
    COUNT(*) AS DuplicateCount,

    -- List duplicate Setting Ids
    (
        SELECT STRING_AGG(CAST(LeagueSettingId AS NVARCHAR(MAX)), ', ')
        FROM (
            SELECT TOP 50 LeagueSettingId
            FROM #DuplicateCheck AS c
            WHERE c.ConditionKey = dg.ConditionKey
            ORDER BY LeagueSettingId
        ) AS x
    ) AS SettingIds,

    -- List League Names
    (
        SELECT STRING_AGG(LeagueName, ', ')
        FROM (
            SELECT DISTINCT TOP 50 LeagueName
            FROM #DuplicateCheck AS c
            WHERE c.ConditionKey = dg.ConditionKey
            ORDER BY LeagueName
        ) AS x
    ) AS LeagueNames,

    -- List League Ids
    (
        SELECT STRING_AGG(CAST(OWPLeagueId AS NVARCHAR(MAX)), ', ')
        FROM (
            SELECT TOP 50 OWPLeagueId
            FROM #DuplicateCheck AS c
            WHERE c.ConditionKey = dg.ConditionKey
            ORDER BY OWPLeagueId
        ) AS x
    ) AS LeagueIds

FROM #DuplicateCheck dg
GROUP BY ConditionKey
HAVING COUNT(*) > 1;
-- Show detailed results for duplicates
SELECT
    dc.LeagueSettingId,
    dc.OWPLeagueId,
    dc.LeagueName,
    dc.FullConditionDescription,
    dc.HasTv,
    dc.HasIpTv,
    dc.IpTv,
    dc.Remark,
    dc.Round_Type,
    dc.Round_Value,
    dc.Round_Index,
    dc.Division_Type,
    dc.Division_Value,
    dc.Division_Index,
    dg.DuplicateCount,
    dg.SettingIds,
    dg.LeagueNames,
    dg.LeagueIds
FROM #DuplicateCheck dc
INNER JOIN #DuplicateGroups dg ON dc.ConditionKey = dg.ConditionKey
ORDER BY dg.DuplicateCount DESC, dc.ConditionKey, dc.LeagueSettingId, dc.Round_Index, dc.Division_Index;

-- Show summary of duplicates
SELECT
    ConditionKey,
    DuplicateCount,
    SettingIds,
    LeagueNames,
    LeagueIds
FROM #DuplicateGroups
ORDER BY DuplicateCount DESC, ConditionKey;

-- Cleanup
DROP TABLE #DuplicateGroups;
DROP TABLE #DuplicateCheck;
DROP TABLE #ParsedLeagueSettings;



/*
*UEFA CONFERENCE LEAGUE (PLAY OFF)
AFRICA CUP OF NATIONS 2025 (IN MOROCCO)
ALBANIA CUP
AZERBAIJAN LEAGUE U19
BRAZIL SANTA CATARINA CUP U20
ENGLISH RESERVE LEAGUE
FRANCE CUP
GREECE CUP
INTERNATIONAL TOURNAMENT (IN GERMANY)(1x45mins)
MEPPEN TOURNAMENT (IN GERMANY)(1x45 mins)
THAILAND PRE SEASON CUP
TROPHY RAMON DE CARRANZA (IN CADIZ)
UEFA CONFERENCE LEAGUE QUALIFIERS
UEFA EURO 2024 QUALIFIERS
UEFA EUROPA CONFERENCE LEAGUE
UEFA EUROPA LEAGUE QUALIFIERS (PLAY OFF)
UEFA U21 CHAMPIONSHIP 2027 QUALIFIERS
UEFA WOMEN CUP QUALIFIERS
URUGUAY CAMPEONATO B U19
USA MLS NEXT PRO
*/


-- Query specific leagues with parsed FullConditionDescription
SELECT
    dc.Id as LeagueSettingId,
    dc.OWPLeagueId,
    l.OWPLeagueName as LeagueName,

    -- TV-related data from JSON
    JSON_VALUE(dc.FullConditionDescription, '$.HasTv') as HasTv,
    JSON_VALUE(dc.FullConditionDescription, '$.HasIpTv') as HasIpTv,
    JSON_VALUE(dc.FullConditionDescription, '$.IpTv') as IpTv,

    -- Round array items (expanded to separate rows would be complex, so we'll show concatenated)
    STUFF((
        SELECT ', ' + CONCAT(rnd.[Type], ':', rnd.[Value])
        FROM OPENJSON(dc.FullConditionDescription, '$.Round') WITH (
            [Type] NVARCHAR(50),
            [Value] NVARCHAR(200),
            [key] NVARCHAR(10)
        ) rnd
        ORDER BY CAST(rnd.[key] AS INT)
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as Round_Conditions,

    -- Division array items (expanded to separate rows would be complex, so we'll show concatenated)
    STUFF((
        SELECT ', ' + CONCAT(div.[Type], ':', div.[Value])
        FROM OPENJSON(dc.FullConditionDescription, '$.Division') WITH (
            [Type] NVARCHAR(50),
            [Value] NVARCHAR(200),
            [key] NVARCHAR(10)
        ) div
        ORDER BY CAST(div.[key] AS INT)
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') as Division_Conditions,

    -- Remark from JSON
    JSON_VALUE(dc.FullConditionDescription, '$.Remark') as Remark,

    -- Full JSON for reference
    dc.FullConditionDescription,

    -- Other setting fields
    dc.Spread_HDP,
    dc.Spread_OU,
    dc.MaxbetWD_HDP,
    dc.WD_NoOfHDP,
    dc.MaxbetWK_HDP,
    dc.WK_NoOfHDP,
    dc.NoOfferLive,
    dc.Comment

FROM LeagueManagementSetting dc
INNER JOIN OWPLeague l ON l.OWPLeagueId = dc.OWPLeagueId
WHERE l.OWPLeagueName IN (
    'UEFA CONFERENCE LEAGUE (PLAY OFF)',
    'AFRICA CUP OF NATIONS 2025 (IN MOROCCO)',
    'ALBANIA CUP',
    'AZERBAIJAN LEAGUE U19',
    'BRAZIL SANTA CATARINA CUP U20',
    'ENGLISH RESERVE LEAGUE',
    'FRANCE CUP',
    'GREECE CUP',
    'INTERNATIONAL TOURNAMENT (IN GERMANY)(1x45mins)',
    'MEPPEN TOURNAMENT (IN GERMANY)(1x45 mins)',
    'THAILAND PRE SEASON CUP',
    'TROPHY RAMON DE CARRANZA (IN CADIZ)',
    'UEFA CONFERENCE LEAGUE QUALIFIERS',
    'UEFA EURO 2024 QUALIFIERS',
    'UEFA EUROPA CONFERENCE LEAGUE',
    'UEFA EUROPA LEAGUE QUALIFIERS (PLAY OFF)',
    'UEFA U21 CHAMPIONSHIP 2027 QUALIFIERS',
    'UEFA WOMEN CUP QUALIFIERS',
    'URUGUAY CAMPEONATO B U19',
    'USA MLS NEXT PRO'
)
ORDER BY l.OWPLeagueName, dc.Id