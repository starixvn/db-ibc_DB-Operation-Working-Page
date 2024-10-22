
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

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
	20230511@Carlos.nguyen: Insert TotalMatchInGroupMultiple - [Redmine: #187937]
	20230613@Carlos.nguyen: Change datatype - [Redmine: #184832]
	20230824@Mira: Save group 5 mins - [Redmine: #185887]
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
      [TotalMatchInGroupMultiple], 
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
      [ESoccer5MinsGroup], 
      [ESoccer6Mins], 
      [ESoccer15Mins], 
      [ESoccer16Mins], 
      [ESoccer20Mins], 
      [Others], 
      [OthersProductOWPMatchIds], 
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
                   [TotalMatchInGroupMultiple], 
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
                   [ESoccer5MinsGroup], 
                   [ESoccer6Mins], 
                   [ESoccer15Mins], 
                   [ESoccer16Mins], 
                   [ESoccer20Mins], 
                   [Others], 
                   [OtherProductMatchIds], 
                   GETDATE()
            FROM OPENXML(@idoc, '/Root/LAReportModel', 1) WITH([UserId] INT, [TotalMatches] MONEY, [Link2] MONEY, [Link3] MONEY, [Link4] MONEY, [Link5] MONEY, [Link6] MONEY, [Link7] MONEY, [Link8Plus] MONEY, [TotalMatchInGroupMultiple] MONEY, [OnlyProvider] MONEY, [OnlyTV] MONEY, [OnlyReporter] MONEY, [MixedProviderTVReporter] MONEY, [CornerPlus] MONEY, [TBookingPlus] MONEY, [Fantasy] MONEY, [GoalKick] MONEY, [OtherProducts] MONEY, [FTCorner] MONEY, [FTCorner5ML] MONEY, [FiveMajorLeague] MONEY, [ESoccer5Mins] MONEY, [ESoccer5MinsGroup] MONEY, [ESoccer6Mins] MONEY, [ESoccer15Mins] MONEY, [ESoccer16Mins] MONEY, [ESoccer20Mins] MONEY, [Others] MONEY, [OtherProductMatchIds] VARCHAR(MAX));
     EXEC sp_xml_removedocument 
          @idoc;