
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LiveDetail_User_GetAll] @AllUserJson VARCHAR(MAX)
AS

/*  
 Created: Raymond.Le@20180907
 Task : Get all user for assignment
 DB: bodb_OWP

 Revisions:
	20181009@Leo.Vo: New structure of event assignment - [Redmine: #92868]
	20181015@Kane.Le Get Nickname as Username if NULL - [Redmine: #103202]
	20190326@Kane.Le Get Only Active Users - [Redmine: #103202]
	20190405@Kane.Le Get the second account column (row 42) - [Redmine: #111068]
	20190503@Kane.Le Get IsSecondAccount - [Redmine: #111840]
	20190521@Leo.Vo: Add Username value - [Feature: #113765]
	20190704@Leo.Vo: Change message template - [Feature: #115459]
	20191024@Kane.Le: Get EmployeeId - [Feature: #122604]
	20240925@Los: Remove NAP_UserControl [Redmine: #209152]
*/

    BEGIN
        SET NOCOUNT ON;
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
        CREATE TABLE #tblFinalUserId(UserId INT);
        SELECT u.UserId, 
               u.EmployeeId, 
               u.Username, 
               u.Nickname, 
               u.Extension, 
               u.Phone, 
               u.Skype, 
               u.IsSecondAccount
        FROM dbo.[User] AS u WITH(NOLOCK)
             INNER JOIN bodb02.dbo.custInfo AS ci WITH(NOLOCK) ON u.UserId = ci.custid
             INNER JOIN @tblAllUser AS us ON us.UserId = u.UserId
        WHERE ci.closed = 0
              AND ci.reject = 0
              AND ci.[Enabled] = 1
              AND us.IsActive = 1
        ORDER BY u.Username;
    END;