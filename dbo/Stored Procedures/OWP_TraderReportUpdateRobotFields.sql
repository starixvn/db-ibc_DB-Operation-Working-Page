USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_TraderReportUpdateRobotFields]    Script Date: 3/13/2023 3:01:54 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReportUpdateRobotFields] @EventDate DATETIME, 
                                                          @Xml       NVARCHAR(MAX)
AS

/*
Created: 20200815@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP

Revisions:
	20200815@Jacob: Archive plan for OWP tables - [Redmine: #137757]
	20230228@Los: Insert if not exists - [Redmine: #184170]
	
*/

     SET NOCOUNT ON;

     -- Parameters
     CREATE TABLE #tmpTable
     (UserId INT, 
      X2     INT, 
      X3     INT, 
      X3Plus INT, 
      X5     INT
     );
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @Xml;
     INSERT INTO #tmpTable
            SELECT UserId, 
                   X2, 
                   X3, 
                   X3Plus, 
                   X5
            FROM OPENXML(@idoc, '/Root/RobotByByUser', 1) WITH(UserId INT, X2 INT, X3 INT, X3Plus INT, X5 INT);
     EXEC sp_xml_removedocument 
          @idoc;
     MERGE dbo.TraderReport AS TARGET
     USING #tmpTable AS SOURCE
     ON(TARGET.UserId = SOURCE.UserId
        AND CAST(TARGET.ReportDate AS DATE) = @EventDate)
         WHEN MATCHED AND TARGET.UserId = SOURCE.UserId
                          AND CAST(TARGET.ReportDate AS DATE) = @EventDate
         THEN UPDATE SET 
                         TARGET.Robot3_X2 = SOURCE.X2, 
                         TARGET.Robot3_X3 = SOURCE.X3, 
                         TARGET.Robot3_X3_plus = SOURCE.X3Plus, 
                         TARGET.Robot5_X5 = SOURCE.X5
         WHEN NOT MATCHED BY TARGET
         THEN
           INSERT(ReportDate, 
                  UserId, 
                  Username, 
                  Robot3_X2, 
                  Robot3_X3, 
                  Robot3_X3_plus, 
                  Robot5_X5, 
                  CreatedDate)
           VALUES
     (@EventDate, 
      SOURCE.UserId, 
      NULL, 
      SOURCE.X2, 
      SOURCE.X3, 
      SOURCE.X3Plus, 
      SOURCE.X5, 
      GETDATE()
     );
     UPDATE t
       SET 
           t.Username = u.Username
     FROM TraderReport t
          INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.UserId = t.UserId
     WHERE t.Username IS NULL;
     DROP TABLE #tmpTable;

     /* End */