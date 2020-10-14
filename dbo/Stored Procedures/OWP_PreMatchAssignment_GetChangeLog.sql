
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_PreMatchAssignment_GetChangeLog] @PageSize   INT = 10, 
                                                            @PageNumber INT = 1, 
                                                            @IsDay      BIT = 1
AS

/*      
 Created: 20200811@Mira.Nguyen
 Task : Pre-match Assignment
 DB: bodb_OWP      
 
 Revisions:
    20200811@Mira.Nguyen: Init sp - [Redmine: #138643]
	20200819@Esther.Nguyen: query change log by pagesize and pagenumber  - [Redmine: #138643]
	20200930@Tyler: update other assignments  - [Redmine: #142258]  
*/

     SET NOCOUNT ON;
     DECLARE @FromRowNum INT= (@PageNumber - 1) * @PageSize + 1;
     DECLARE @ToRowNum INT= @PageNumber * @PageSize;
     DECLARE @FromRowNumNext INT= (@PageNumber) * @PageSize + 1;
     DECLARE @ToRowNumNext INT= (@PageNumber + 1) * @PageSize;
     DECLARE @IsLastPage BIT;
     DECLARE @tblLogAction TABLE
     (ActionId INT
      PRIMARY KEY
     );
     INSERT INTO @tblLogAction(ActionId)
     VALUES(113), (114), (115), (116), (117), (119);

     ---- insert table LogInfo----
     DECLARE @tblLogInfo TABLE
     (RowNumber    INT, 
      LastModified DATETIME
     );
     INSERT INTO @tblLogInfo
     (RowNumber, 
      LastModified
     )
            SELECT RowNumber, 
                   LastModified
            FROM(SELECT ROW_NUMBER() OVER(
                        ORDER BY ul.UserLogId DESC) AS RowNumber, 
                        ul.LoggedDate AS LastModified
                 FROM dbo.UserLog AS ul WITH(NOLOCK)
                      INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId) AS Paging
            WHERE RowNumber BETWEEN @FromRowNumNext AND @ToRowNumNext
            ORDER BY RowNumber, 
                     LastModified DESC;

     --- select data ---
     SELECT RowNumber, 
            LeagueName, 
            [Action], 
            OldValue, 
            NewValue, 
            LastModified, 
            ModifiedBy
     FROM(
         SELECT ROW_NUMBER() OVER(
                ORDER BY ul.UserLogId DESC) AS RowNumber, 
                ISNULL(l.OWPLeagueName, 'All') AS LeagueName, 
                (CASE
                     WHEN lat.ActionTypeId = 2
                          AND sp.ActionId = 113
                     THEN 'Update Assignment'
                     WHEN lat.ActionTypeId = 3
                          AND sp.ActionId = 114
                     THEN 'Delete League'
                     WHEN lat.ActionTypeId = 4
                          AND sp.ActionId = 115
                     THEN 'Recover League'
                     WHEN lat.ActionTypeId = 2
                          AND sp.ActionId = 116
                     THEN 'Update Remark'
                     WHEN lat.ActionTypeId = 2
                          AND sp.ActionId = 117
                     THEN 'Change Start Time'
                     WHEN lat.ActionTypeId = 2
                          AND sp.ActionId = 119
                     THEN 'Update Other Assignment'
                 END) AS [Action], 
                ul.DataOld AS OldValue, 
                ul.Data AS NewValue, 
                ul.LoggedDate AS LastModified, 
                u.Username AS ModifiedBy
         FROM dbo.UserLog AS ul WITH(NOLOCK)
              INNER JOIN @tblLogAction AS sp ON ul.ActionId = sp.ActionId
              LEFT JOIN PreMatchLeague AS p WITH(NOLOCK) ON p.PreMatchLeagueId = ul.ObjectId
              LEFT JOIN OWPLeague AS l WITH(NOLOCK) ON l.OWPLeagueId = p.OWPLeagueId
              LEFT JOIN dbo.[User] AS u WITH(NOLOCK) ON ul.CreatorId = u.UserId
              LEFT JOIN LogAction AS la WITH(NOLOCK) ON la.ActionId = ul.ActionId
              LEFT JOIN LogActionType AS lat WITH(NOLOCK) ON lat.ActionTypeId = la.ActionTypeId
         WHERE(ul.ActionId <> 117
               AND p.IsDay = @IsDay)
              OR ul.ActionId = 117) AS Paging
     WHERE RowNumber BETWEEN @FromRowNum AND @ToRowNum
     ORDER BY RowNumber, 
              LastModified DESC;

     --- check last page ---
     IF EXISTS
     (
         SELECT 1
         FROM @tblLogInfo
     )
         BEGIN
             SET @IsLastPage = 0;
         END;
         ELSE
         BEGIN
             SET @IsLastPage = 1;
         END;
     SELECT @IsLastPage 'IsLastPage';