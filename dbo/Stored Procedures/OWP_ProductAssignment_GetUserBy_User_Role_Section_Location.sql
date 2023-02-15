USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section]    Script Date: 05/13/2021 11:30:08 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section_Location] @SectionId  VARCHAR(100), 
                                                                                   @LocationId VARCHAR(100), 
                                                                                   @User       VARCHAR(30)  = NULL, 
                                                                                   @RoleId     VARCHAR(100) = NULL, 
                                                                                   @SiteId     INT
AS

/*
Created: 20230213@carlos.nguyen
Task : Get product assignment preferences 
DB: bodb_OWP

Revisions:
	20230213@carlos.nguyen: Init SP - [Redmine: #183243]  	 
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @UserName VARCHAR(30);
        SELECT @UserName = RTRIM(LTRIM(@User));
        DECLARE @tempSection TABLE(SectionId SMALLINT);
        DECLARE @tempLocation TABLE(LocationId VARCHAR(5));
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

        SELECT DISTINCT 
               u.Username, 
               u.UserId, 
               u.[Level] AS [LevelId], 
               ur.RoleId, 
               u.BetTypePreferencesId, 
               u.MultipleGamesId, 
               u.AssignmentRemark, 
               u.SectionId
        FROM [User] AS u WITH(NOLOCK)
             INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
             INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH(NOLOCK) ON us.UserId = u.UserId
                                                                                     AND us.SiteId = @SiteId
             LEFT JOIN @tempSection AS t ON u.SectionId = t.SectionId
             LEFT JOIN @tempLocation AS tl ON tl.LocationId = u.LocationCode
             LEFT JOIN [UserRole] AS ur ON ur.UserId = u.UserId
             LEFT JOIN @tempRole AS tr ON ur.RoleId = tr.RoleId
        WHERE(ci.closed = 0
              AND ci.reject = 0
              AND ci.[Enabled] = 1
              AND us.IsActive = 1)
             AND u.IsSecondAccount = 0
             AND (ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
                  OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%')
             AND u.SectionId = t.SectionId
             AND u.LocationCode = tl.LocationId
             AND ISNULL(ur.RoleId, 0) = ISNULL(tr.RoleId, 0);
    END;