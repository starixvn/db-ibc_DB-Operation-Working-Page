/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_EventPicking_SpecialProduct_GetMaxbetSpread] @InfositeMatchIds VARCHAR (MAX)
AS	
/*
Created: 20251022@Los
Task :Get maxbet/spread child match from live setting
DB: bodb_OWP

Revisions:
	20251022@Los: Get maxbet/spread child match from live setting - [Redmine: #238985]
*/

BEGIN
	SET NOCOUNT ON
    -- InfositeMatchId of parent match
	 CREATE TABLE #tblMainMatchInfo
        (InfositeMatchId INT
        );
	INSERT INTO #tblMainMatchInfo
        (InfositeMatchId
        )
               SELECT DISTINCT value
    FROM STRING_SPLIT(@InfositeMatchIds, ',');

    CREATE TABLE #tblResult(
    InfositeMatchId INT,
        NoOfCornerFTHDP MONEY,
        NoOfCornerFTOU MONEY,
        NextCornerFTHDP MONEY,
        TotalBookingFTHDP MONEY,
        TotalBookingFTOU MONEY,
        NextBookingFTHDP MONEY,
        MapDefault BIT -- //-1000
    );

    INSERT INTO #tblResult(InfositeMatchId,
    NoOfCornerFTHDP,
        NoOfCornerFTOU,
        NextCornerFTHDP,
        TotalBookingFTHDP,
        TotalBookingFTOU,
        NextBookingFTHDP)
    SELECT evt.InfositeMatchId,
      mb.NoOfCorner_FT_HDP   'NoOfCornerFTHDP',
      mb.NoOfCorner_FT_OU    'NoOfCornerFTOU',
      mb.NextCorner_FT_HDP   'NextCornerFTHDP',
      mb.TotalBooking_FT_HDP 'TotalBookingFTHDP',
      mb.TotalBooking_FT_OU  'TotalBookingFTOU',
      mb.NextBooking_FT_HDP  'NextBookingFTHDP'
      FROM EventPicking AS evt WITH (NOLOCK) 
      INNER JOIN #tblMainMatchInfo AS tblc WITH (NOLOCK) ON evt.InfositeMatchId=tblc.InfositeMatchId
      INNER JOIN MaxbetSetting AS mb WITH (NOLOCK) ON evt.MaxbetHdp=mb.FT_HDP;

    INSERT INTO #tblResult(InfositeMatchId,
        NoOfCornerFTHDP,
        NoOfCornerFTOU,
        NextCornerFTHDP,
        TotalBookingFTHDP,
        TotalBookingFTOU,
        NextBookingFTHDP)
      SELECT tblc.InfositeMatchId,
      mb.NoOfCorner_FT_HDP   'NoOfCornerFTHDP',
      mb.NoOfCorner_FT_OU    'NoOfCornerFTOU',
      mb.NextCorner_FT_HDP   'NextCornerFTHDP',
      mb.TotalBooking_FT_HDP 'TotalBookingFTHDP',
      mb.TotalBooking_FT_OU  'TotalBookingFTOU',
      mb.NextBooking_FT_HDP  'NextBookingFTHDP'
      FROM #tblMainMatchInfo AS tblc WITH (NOLOCK)
      INNER JOIN MaxbetSetting AS mb WITH (NOLOCK) ON mb.FT_HDP=-1000
      LEFT JOIN #tblResult AS result WITH (NOLOCK) ON tblc.InfositeMatchId=result.InfositeMatchId
      WHERE result.InfositeMatchId IS NULL

    SELECT InfositeMatchId,
        NoOfCornerFTHDP,
        NoOfCornerFTOU,
        NextCornerFTHDP,
        TotalBookingFTHDP,
        TotalBookingFTOU,
        NextBookingFTHDP
     FROM #tblResult;

      DROP TABLE #tblMainMatchInfo;
      DROP TABLE #tblResult;
END