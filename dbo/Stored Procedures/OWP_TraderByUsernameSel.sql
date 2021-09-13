
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TraderByUsernameSel] @Username NVARCHAR(MAX) = ''
AS

/*
Created: 20200310@Jacob
Task : Assignment Uploading
DB: bodb_OWP

Revisions:
	20200310@Jacob: New structure of Assignment Uploading - [Redmine: #129397]
	20210913@Tyler: Hot fix - Allow username with 200 characters [Redmine: #137209]
	
*/

     SET NOCOUNT ON;
     -- temp User
     DECLARE @tempUser TABLE(Username NVARCHAR(200));
     INSERT INTO @tempUser
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Username, ',') u OPTION(MAXRECURSION 0);
     DECLARE @duplicatedUser TABLE(Username NVARCHAR(200));
     -- Duplicated User
     INSERT INTO @duplicatedUser(Username)
            SELECT t.Username
            FROM @tempUser t
                 INNER JOIN dbo.[User] AS u WITH(NOLOCK) ON t.Username = u.Username
                                                            OR t.Username = u.NickName
            GROUP BY t.Username
            HAVING COUNT(u.UserId) > 1;

     -- Result
     SELECT t.Username, 
            ISNULL(u.UserId, 0) AS UserId,
            CASE
                WHEN d.Username IS NULL
                THEN 0
                ELSE 1
            END AS IsDuplicate
     FROM @tempUser t
          LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON (t.Username = u.Username
                                                    OR t.Username = u.NickName) AND u.IsSecondAccount = 0
          LEFT JOIN @duplicatedUser d ON d.Username = t.Username;
