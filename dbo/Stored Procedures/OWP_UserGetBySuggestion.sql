/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_UserGetBySuggestion] @Keyword     NVARCHAR(100), 
                                                @AllUserJson VARCHAR(MAX)
AS

/*
 Created: 20161226@Razor.Nguyen
 Task : Get Users by suggestion.
 DB: bodb_OWP

 Revisions: 
	20180914@Kane.Le: Get Username output - [Redmine: #92868]
	20181015@Kane.Le Get Nickname as Username if NULL - [Redmine: #103202]
	20190503@Kane.Le Get IsSecondAccount - [Redmine: #111840]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20190704@Leo.Vo: Change message template - [Feature: #115459]
	20240925@Los: Remove NAP_UserControl [Redmine: #209152]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @tblAllUser TABLE(UserId INT NOT NULL);
        INSERT INTO @tblAllUser(UserId)
               SELECT *
               FROM OPENJSON(@AllUserJson) WITH(UserId INT);
        CREATE TABLE #tblUsers
        (UserId   INT, 
         Username VARCHAR(30), 
         Nickname VARCHAR(30)
        );
        INSERT INTO #tblUsers
        (UserId, 
         Username, 
         Nickname
        )
               SELECT TOP 10 u.UserId, 
                             u.Username, 
                             u.Nickname
               FROM dbo.[User] AS u WITH(NOLOCK)
                    INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
                    INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
               WHERE u.IsSecondAccount = 0
                     AND (u.Username LIKE @Keyword + '%'
                          OR u.Nickname LIKE @Keyword + '%');
        SELECT UserId, 
               Username, 
               Nickname
        FROM #tblUsers WITH(NOLOCK)
        ORDER BY Username;
        DROP TABLE #tblUsers;
    END;