
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section_Location] @SectionId   VARCHAR(100), 
                                                                                   @LocationId  VARCHAR(100), 
                                                                                   @User        VARCHAR(30)  = NULL, 
                                                                                   @RoleId      VARCHAR(100) = NULL, 
                                                                                   @AllUserJson VARCHAR(MAX)
AS

/*
Created: 20230213@carlos.nguyen
Task : Get product assignment preferences 
DB: bodb_OWP

Revisions:
	20230213@carlos.nguyen: Init SP - [Redmine: #183243]
	20240110@Mira: Edit location type - [Redmine: #199132]
	20240925@Los: Remove NAP_UserControl [Redmine: #209152]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @UserName VARCHAR(30);
        SELECT @UserName = RTRIM(LTRIM(@User));
        DECLARE @tblAllUser TABLE
        (UserId   INT NOT NULL, 
         IsActive BIT
        );
        INSERT INTO @tblAllUser
        (UserId, 
         IsActive
        )
               SELECT *
               FROM OPENJSON(@AllUserJson) WITH(UserId INT, IsActive BIT);
        DECLARE @tempBettype TABLE
        (UserId               INT, 
         BetTypePreferencesId NVARCHAR(100)
        );
        INSERT INTO @tempBettype
               SELECT ub.UserId, 
                      STRING_AGG(ub.BetTypeId, ',') AS 'BetTypePreferencesId'
               FROM UserBetTypePreferences AS ub
               GROUP BY ub.UserId;
        DECLARE @tempSection TABLE(SectionId SMALLINT);
        DECLARE @tempLocation TABLE(LocationId VARCHAR(20));
        DECLARE @tempRole TABLE(RoleId SMALLINT);
        INSERT INTO @tempSection
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@SectionId, ',') u OPTION(MAXRECURSION 0);
        INSERT INTO @tempLocation
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@LocationId, ',') u OPTION(MAXRECURSION 0);
        INSERT INTO @tempRole
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@RoleId, ',') u OPTION(MAXRECURSION 0);
        --temp table
        DECLARE @tblUserAllRole TABLE
        (Username             NVARCHAR(MAX), 
         UserId               INT, 
         LevelId              INT, 
         RoleId               INT, 
         BetTypePreferencesId NVARCHAR(MAX), 
         MultipleGamesId      INT, 
         AssignmentRemark     NVARCHAR(MAX), 
         SectionId            INT
        );
        INSERT INTO @tblUserAllRole
        (Username, 
         UserId, 
         LevelId, 
         RoleId, 
         BetTypePreferencesId, 
         MultipleGamesId, 
         AssignmentRemark, 
         SectionId
        )
               SELECT DISTINCT 
                      u.Username, 
                      u.UserId, 
                      u.[Level] AS [LevelId],
                      CASE
                          WHEN ISNULL(ur.RoleId, 0) = 0
                          THEN 0
                          ELSE ur.RoleId
                      END, 
                      tb.BetTypePreferencesId, 
                      u.MultipleGamesId, 
                      u.AssignmentRemark, 
                      u.SectionId
               FROM [User] AS u WITH(NOLOCK)
                    INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
                    INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
                    INNER JOIN @tempSection AS t ON u.SectionId = t.SectionId
                    INNER JOIN @tempLocation AS tl ON tl.LocationId = ISNULL(u.LocationCode, 'None')
                    LEFT JOIN [UserRole] AS ur ON ur.UserId = u.UserId
                    LEFT JOIN @tempBettype AS tb ON u.UserId = tb.UserId
               WHERE(ci.closed = 0
                     AND ci.reject = 0
                     AND ci.[Enabled] = 1
                     AND us.IsActive = 1)
                    AND u.IsSecondAccount = 0
                    AND (ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
                         OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%');
        SELECT tu.Username, 
               tu.UserId, 
               tu.LevelId, 
               tu.RoleId, 
               tu.BetTypePreferencesId, 
               tu.MultipleGamesId, 
               tu.AssignmentRemark, 
               tu.SectionId
        FROM @tblUserAllRole AS tu
             INNER JOIN @tempRole AS tr ON tu.RoleId = tr.RoleId;
    END;