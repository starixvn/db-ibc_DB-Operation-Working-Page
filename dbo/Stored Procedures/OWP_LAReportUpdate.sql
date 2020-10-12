
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LAReportUpdate] @EventDate DATETIME, 
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

     -- DELETE Data
     DELETE dbo.LAReport
     WHERE ReportDate = @EventDate;

     -- INSERT Data
     DECLARE @idoc INT;
     EXEC sp_xml_preparedocument 
          @idoc OUTPUT, 
          @Xml;
     INSERT INTO [dbo].[LAReport]
     ([ReportDate], 
      [UserId], 
      [Username], 
      [TotalMatches], 
      [LinkLowerThan3], 
      [LinkX3], 
      [LinkX6], 
      [LinkX9Plus], 
      [ProviderTv], 
      [Provider], 
      [TV], 
      [Reporter], 
      [CornerPlus], 
      [TBookingPlus], 
      [Fantasy], 
      [GoalKick], 
      [OtherProducts], 
      [FTCorner], 
      [ESoccer5Mins], 
      [ESoccer15Mins], 
      [ESoccer20Mins], 
      [Others], 
      [CreatedDate]
     )
            SELECT @EventDate, 
                   [UserId], 
                   [Username], 
                   [TotalMatches], 
                   [LinkLowerThan3], 
                   [LinkX3], 
                   [LinkX6], 
                   [LinkX9Plus], 
                   [ProviderTv], 
                   [Provider], 
                   [TV], 
                   [Reporter], 
                   [CornerPlus], 
                   [TBookingPlus], 
                   [Fantasy], 
                   [GoalKick], 
                   [OtherProducts], 
                   [FTCorner], 
                   [ESoccer5Mins], 
                   [ESoccer15Mins], 
                   [ESoccer20Mins], 
                   [Others], 
                   GETDATE()
            FROM OPENXML(@idoc, '/Root/LAReportModel', 1) WITH([UserId] [INT], [Username] [VARCHAR](50), [TotalMatches] [INT], [LinkLowerThan3] INT, [LinkX3] INT, [LinkX6] INT, [LinkX9Plus] INT, [ProviderTv] INT, [Provider] INT, [TV] INT, [Reporter] INT, [CornerPlus] INT, [TBookingPlus] INT, [Fantasy] INT, [GoalKick] INT, [OtherProducts] INT, [FTCorner] INT, [ESoccer5Mins] INT, [ESoccer15Mins] INT, [ESoccer20Mins] INT, [Others] INT);
     EXEC sp_xml_removedocument 
          @idoc;