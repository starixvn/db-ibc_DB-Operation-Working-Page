
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_QueryDayShift] @EventDate DATE
    ,@EventFromDateTime DATETIME
    ,@EventToDateTime DATETIME
    ,@IsDay BIT
AS
/*
Created: 20200811@Esther.Nguyen
Task : Query day shift
DB: bodb_OWP

Revisions:
    20200813@Esther.Nguyen: query day shift  - [Redmine: #138643]
    20200903@Tyler: query matches  - [Redmine: #140620]
    20201003@Tyler: get other assignments  - [Redmine: #142258]
    20201020@Esther: Remove EventDate  - [Redmine: #143792]
    20201029@Tyler: Clone assignment to NightShift  - [Redmine: #144400]
    20201110@Tyler: remove other assignment note - [Redmine: #144948]
    20210607@Mira: Link Match Status - [Redmine: #156336]
    20211222@Mira: Integrate my ticket - [Redmine: #163766]
    20220216@Johnny: get match parentId is null only - [Redmine: #168050]
    20220321@Mira: get AdminsiteId - [Redmine: #170097]
    20230607@Mira: get LeagueId for InfositeMatch - [Redmine: #186299]
    20231026@los: sync round - [Redmine: #193810]
    20231219@Liam: Get League Group - [Redmine: #198232]
    20241209@Frankie : Update League Category - [Feature: #214351]
    20241108@Tim: auto assign - [Redmine: #205720]
*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @hpdBettype INT= 1;
    DECLARE @ouBettype INT= 3;

    -- main assignments
    DECLARE @tblHDPMainAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblHDPMainAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @hpdBettype,
        @IsTakeOver = 0,
        @AssignmentType = 1;

    --
    DECLARE @tblOUMainAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOUMainAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @ouBettype,
        @IsTakeOver = 0,
        @AssignmentType = 1;

    --
    DECLARE @tblHDPTOMainAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblHDPTOMainAssignment
    (
        PreMatchLeagueId, 
        UserName, 
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @hpdBettype,
        @IsTakeOver = 1,
        @AssignmentType = 1;

    --
    DECLARE @tblOUTOMainAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOUTOMainAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment]
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @ouBettype,
        @IsTakeOver = 1,
        @AssignmentType = 1;

    ---- insert usernames for OtherAssignments
    DECLARE @tblOtherHDPAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOtherHDPAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment]
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @hpdBettype,
        @IsTakeOver = 0,
        @AssignmentType = 2;

    --
    DECLARE @tblOtherOUAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOtherOUAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment]
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @ouBettype,
        @IsTakeOver = 0,
        @AssignmentType = 2;

    --
    DECLARE @tblOtherHDPTOAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOtherHDPTOAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment] 
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @hpdBettype,
        @IsTakeOver = 1,
        @AssignmentType = 2;

    --
    DECLARE @tblOtherOUTOAssignment TABLE
    (
        PreMatchLeagueId INT,
        UserName VARCHAR(MAX),
        Nickname VARCHAR(MAX)
    );
    INSERT INTO @tblOtherOUTOAssignment
    (
        PreMatchLeagueId,
        UserName,
        Nickname
    )
    EXEC dbo.[OWP_PreMatchAssignment_QueryMainAssignment]
        @EventDate = @EventDate,
        @IsDay = @IsDay,
        @Bettype = @ouBettype,
        @IsTakeOver = 1,
        @AssignmentType = 2;

    ---- match count for league ----
    DECLARE @tblMatchCount TABLE
    (
        OWPLeagueId VARCHAR(MAX),
        MatchCount INT
    );
    INSERT INTO @tblMatchCount
    (
        OWPLeagueId,
        MatchCount
    )
    SELECT m1.OWPLeagueId,
        COUNT(1)
    FROM PreMatchLeague AS pl WITH(NOLOCK)
        INNER JOIN InfoSiteMatch AS m1 WITH(NOLOCK) ON m1.OWPLeagueId = pl.OWPLeagueId
    WHERE pl.EventDate = @EventDate
        AND m1.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
        AND pl.IsDay = @IsDay
        AND pl.IsDeleted = 0
        AND m1.ParentId IS NULL
    GROUP BY m1.OWPLeagueId;

    -- insert table day shift--
    DECLARE @tblDayShiftTable TABLE
    (
        PreMatchLeagueId INT,
        LeagueId INT,
        CategoryId INT,
        LeagueName VARCHAR(MAX),
        MatchCount INT,
        HDP VARCHAR(200),
        OU VARCHAR(200),
        HDPTakeOver VARCHAR(200),
        OUTakeOver VARCHAR(200),
        HDPNickname VARCHAR(200),
        OUNickname VARCHAR(200),
        HDPTakeOverNickname VARCHAR(200),
        OUTakeOverNickname VARCHAR(200),
        OtherHDP VARCHAR(200),
        OtherOU VARCHAR(200),
        OtherHDPTakeOver VARCHAR(200),
        OtherOUTakeOver VARCHAR(200),
        OtherHDPNickname VARCHAR(200),
        OtherOUNickname VARCHAR(200),
        OtherHDPTakeOverNickname VARCHAR(200),
        OtherOUTakeOverNickname VARCHAR(200),
        BlackList BIT,
        Remark NVARCHAR(MAX),
        IsDeleted BIT
    );
    INSERT INTO @tblDayShiftTable
    (
        PreMatchLeagueId,
        LeagueId,
        CategoryId,
        LeagueName,
        MatchCount,
        HDP,
        OU,
        HDPTakeOver,
        OUTakeOver,
        HDPNickname,
        OUNickname,
        HDPTakeOverNickname,
        OUTakeOverNickname,
        OtherHDP,
        OtherOU,
        OtherHDPTakeOver,
        OtherOUTakeOver,
        OtherHDPNickname,
        OtherOUNickname,
        OtherHDPTakeOverNickname,
        OtherOUTakeOverNickname,
        BlackList,
        Remark,
        IsDeleted
    )
    SELECT pl.PreMatchLeagueId,
        pl.OWPLeagueId,
        l.CategoryId,
        l.OWPLeagueName,
        a.MatchCount,
        --main
        mh.UserName,
        mo.UserName,
        mht.UserName,
        mot.UserName,
        mh.Nickname,
        mo.Nickname,
        mht.Nickname,
        mot.Nickname,
        --Other
        oh.UserName,
        oo.UserName,
        oht.UserName,
        oot.UserName,
        oh.Nickname,
        oo.Nickname,
        oht.Nickname,
        oot.Nickname,
        l.IsBlackList,
        pl.Remark,
        pl.IsDeleted
    FROM PreMatchLeague AS pl WITH(NOLOCK)
        INNER JOIN OWPLeague AS l WITH(NOLOCK) ON pl.OWPLeagueId = l.OWPLeagueId
        INNER JOIN @tblMatchCount AS a ON a.OWPLeagueId = l.OWPLeagueId
        LEFT JOIN @tblHDPMainAssignment AS mh ON mh.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOUMainAssignment AS mo ON mo.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblHDPTOMainAssignment AS mht ON mht.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOUTOMainAssignment AS mot ON mot.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOtherHDPAssignment AS oh ON oh.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOtherOUAssignment AS oo ON oo.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOtherHDPTOAssignment AS oht ON oht.PreMatchLeagueId = pl.PreMatchLeagueId
        LEFT JOIN @tblOtherOUTOAssignment AS oot ON oot.PreMatchLeagueId = pl.PreMatchLeagueId
    WHERE pl.EventDate = @EventDate
        AND pl.IsDay = @IsDay;

    -- Table league notes
    DECLARE @tblLeagueNotes TABLE
    (
        PreMatchNoteId INT,
        OWPLeagueId INT,
        HasNotes BIT
    );
    INSERT INTO @tblLeagueNotes
    EXEC dbo.[OWP_PreMatchAssignment_QueryLeagueNotes] 
        @EventDate = @EventDate;

    --table match notes
    DECLARE @tblMatchNotes TABLE
    (
        PreMatchNoteId  INT,
        InfoSiteMatchId INT,
        HasNotes BIT
    );
    INSERT INTO @tblMatchNotes
    EXEC dbo.[OWP_PreMatchAssignment_QueryInfoSiteMatchNotes] 
        @EventDate = @EventDate;

    -- Result
    --    Query leagues --
    SELECT *
    FROM (
        SELECT PreMatchLeagueId,
            LeagueId,
            LeagueName,
            MatchCount,
            HDP,
            OU,
            HDPTakeOver,
            OUTakeOver,
            HDPNickname,
            OUNickname,
            HDPTakeOverNickname,
            OUTakeOverNickname,
            OtherHDP,
            OtherOU,
            OtherHDPTakeOver,
            OtherOUTakeOver,
            OtherHDPNickname,
            OtherOUNickname,
            OtherHDPTakeOverNickname,
            OtherOUTakeOverNickname,
            BlackList,
            Remark,
            n.PreMatchNoteId,
            n.HasNotes,
            l.IsDeleted,
            [dbo].[fnc_GetLeagueGroupByDate] (@EventDate, l.LeagueId) AS LeagueGroup
        FROM @tblDayShiftTable AS l
            LEFT JOIN @tblLeagueNotes AS n ON n.OWPLeagueId = l.LeagueId
		) AS leaguesInfo
        LEFT JOIN RefResource AS rr WITH(NOLOCK) ON rr.Value = leaguesInfo.LeagueGroup
        AND rr.RefName = 'LeagueCategory';

    -- Query InfoSiteMatches --
    SELECT m.InfoSiteMatchId,
        m.AdminSiteMatchId,
        m.LeagueName,
        m.HomeName,
        m.AwayName,
        m.EventDateTime,
        l.PreMatchLeagueId,
        n.PreMatchNoteId,
        n.HasNotes,
        m.IsLive,
        m.OWPLeagueId 'LeagueId',
        m.TeamRound,
        m.IsTest
    FROM dbo.[InfoSiteMatch] AS m WITH(NOLOCK)
        INNER JOIN @tblDayShiftTable AS l ON l.LeagueId = m.OWPLeagueId
        LEFT JOIN @tblMatchNotes AS n ON n.InfoSiteMatchId = m.InfoSiteMatchId
    WHERE m.EventDateTime BETWEEN @EventFromDateTime AND @EventToDateTime
        AND m.ParentId IS NULL
    ORDER BY m.EventDateTime ASC;
END
