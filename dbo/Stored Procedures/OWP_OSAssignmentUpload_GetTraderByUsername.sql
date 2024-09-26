
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetTraderByUsername] @Username NVARCHAR(MAX) = ''
AS

/*
Created: 20201223@Esther
Task : Event Upload for Othersports
DB: bodb_OWP

Revisions:
	20201223@Esther: New structure of Event Upload for Othersports - [Redmine: #146962]
	
*/

    BEGIN
        SET NOCOUNT ON;
        -- temp User
        DECLARE @tempUser TABLE(Username NVARCHAR(200));
        INSERT INTO @tempUser
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@Username, ',') u OPTION(MAXRECURSION 0);      

        -- Result
        SELECT t.Username, 
               ISNULL(u.UserId, 0) AS UserId
        FROM @tempUser t
             LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON(t.Username = u.Username
                                                       OR t.Username = u.NickName)
                                                      AND u.IsSecondAccount = 0;
    END;