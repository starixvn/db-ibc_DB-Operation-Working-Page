USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section]    Script Date: 05/13/2021 11:30:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_ProductAssignment_GetUserBy_User_Role_Section] 
	@Section VARCHAR(20),
	@User VARCHAR(30) = NULL,
	@RoleId INT = NULL,
	@SiteId INT
AS	
/*
Created: 20210510@carlos.nguyen
Task : Get product assignment preferences 
DB: bodb_OWP

Revisions:
	20210510@carlos.nguyen: Init SP - [Redmine: #154779]  	 
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @UserName VARCHAR(30) 
	SELECT @UserName = RTRIM(LTRIM(@User))
	 DECLARE @tempSection TABLE(SectionId SMALLINT);
     INSERT INTO @tempSection
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Section, ',') u OPTION(MAXRECURSION 0);
		
	SELECT u.Username
		,u.UserId
		,u.[Level] AS [LevelId]
		,ur.RoleId
		,u.BetTypePreferencesId
		,u.MultipleGamesId
		,u.AssignmentRemark
	FROM [User] AS u WITH (NOLOCK)
		INNER JOIN bodb02.dbo.custInfo AS ci WITH (NOLOCK) ON u.UserId = ci.custid
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite AS us WITH (NOLOCK) ON us.UserId = u.UserId AND us.SiteId = @SiteId
		INNER JOIN @tempSection AS t ON u.SectionId = t.SectionId
		LEFT JOIN [UserRole] AS ur ON ur.UserId= u.UserId
	WHERE (ci.closed = 0
				AND ci.reject = 0
				AND ci.[Enabled] = 1
				AND us.IsActive = 1)
			AND (
				ISNULL(u.Username, '') LIKE '%' + ISNULL(@UserName, '') + '%'
				OR ISNULL(u.Nickname, '') LIKE '%' + ISNULL(@UserName, '') + '%'
			)
			AND (
				@RoleId = -1
				OR @RoleId = ISNULL(ur.RoleId, 0)
			)
			AND u.IsSecondAccount=0
END
