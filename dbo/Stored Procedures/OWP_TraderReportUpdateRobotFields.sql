
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_TraderReportUpdateRobotFields] @EventDate DATETIME, 
                                                       @Xml       NVARCHAR(MAX)
AS

/*
Created: 20200815@Jacob
Task : Archive plan for OWP tables
DB: bodb_OWP

Revisions:
	20200815@Jacob: Archive plan for OWP tables - [Redmine: #137757]	
	
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

     -- Update Data
     UPDATE r
       SET 
           r.Robot3_X2 = t.X2, 
           r.Robot3_X3 = t.X3, 
           r.Robot3_X3_plus = t.X3Plus, 
           r.Robot5_X5 = t.X5
     FROM dbo.TraderReport AS r
          INNER JOIN #tmpTable t ON r.UserId = t.UserId
                                    AND r.ReportDate = @EventDate;
     DROP TABLE #tmpTable;