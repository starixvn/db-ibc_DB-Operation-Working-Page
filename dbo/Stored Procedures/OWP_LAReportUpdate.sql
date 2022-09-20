
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
	20210113@Esther: Adding SABA 6mins match to LA Report - [Redmine: #148267]
	20210907@Liam: Adding SABA 16mins match to LA Report - [Redmine: #160544]
	20220408@Johnny: Adding 5ML match to LA Report - [Redmine: #171212]
	20220418@Johnny: Adding FT_Corner_5ML match to LA Report - [Redmine: #171212]
	20220920@Mira: LA Report enhancement - [Redmine: #177768]
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
      [TotalMatches], 
      [Link2], 
      [Link3], 
      [Link4], 
      [Link5], 
      [Link6], 
      [Link7], 
      [Link8Plus], 
      [OnlyProvider], 
      [OnlyTV], 
      [OnlyReporter], 
      [MixedProviderTVReporter], 
      [CornerPlus], 
      [TBookingPlus], 
      [Fantasy], 
      [GoalKick], 
      [OtherProducts], 
      [FTCorner], 
      [FTCorner5ML], 
      [FiveMajorLeague], 
      [ESoccer5Mins], 
      [ESoccer6Mins], 
      [ESoccer15Mins], 
      [ESoccer16Mins], 
      [ESoccer20Mins], 
      [Others], 
      [CreatedDate]
     )
            SELECT @EventDate, 
                   [UserId], 
                   [TotalMatches], 
                   [Link2], 
                   [Link3], 
                   [Link4], 
                   [Link5], 
                   [Link6], 
                   [Link7], 
                   [Link8Plus], 
                   [OnlyProvider], 
                   [OnlyTV], 
                   [OnlyReporter], 
                   [MixedProviderTVReporter], 
                   [CornerPlus], 
                   [TBookingPlus], 
                   [Fantasy], 
                   [GoalKick], 
                   [OtherProducts], 
                   [FTCorner], 
                   [FTCorner5ML], 
                   [FiveMajorLeague], 
                   [ESoccer5Mins], 
                   [ESoccer6Mins], 
                   [ESoccer15Mins], 
                   [ESoccer16Mins], 
                   [ESoccer20Mins], 
                   [Others], 
                   GETDATE()
            FROM OPENXML(@idoc, '/Root/LAReportModel', 1) WITH([UserId] INT, [TotalMatches] INT, [Link2] INT, [Link3] INT, [Link4] INT, [Link5] INT, [Link6] INT, [Link7] INT, [Link8Plus] INT, [OnlyProvider] INT, [OnlyTV] INT, [OnlyReporter] INT, [MixedProviderTVReporter] INT, [CornerPlus] INT, [TBookingPlus] INT, [Fantasy] INT, [GoalKick] INT, [OtherProducts] INT, [FTCorner] INT, [FTCorner5ML] INT, [FiveMajorLeague] INT, [ESoccer5Mins] INT, [ESoccer6Mins] INT, [ESoccer15Mins] INT, [ESoccer16Mins] INT, [ESoccer20Mins] INT, [Others] INT);
     EXEC sp_xml_removedocument 
          @idoc;