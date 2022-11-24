
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_EventPicking_InsertOrDeleteNoOfferMatch] @MatchInfoJson NVARCHAR(MAX), 
                                                                  @ActorId       INT

/*
Created: 20221027@Carlos.nguyen
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20201020@Carlos.nguyen: Insert or delete unselected match - Redmine: #179302
*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (InfoSiteMatchId INT NOT NULL, 
         SubType         INT, 
         IsNoOffer       BIT
        );
        DECLARE @Log TABLE
        (id              INT IDENTITY(1, 1) PRIMARY KEY, 
         InfoSiteMatchId INT NOT NULL, 
         SubType         INT, 
         IsNoOfferOld    BIT, 
         IsNoOfferNew    BIT
        );
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @XmlLogOld XML, @XmlLogNew XML, @LogOld NVARCHAR(MAX), @LogNew NVARCHAR(MAX);
        SET @StartRun = GETDATE();
        INSERT INTO @Temp
        (InfoSiteMatchId, 
         SubType, 
         IsNoOffer
        )
               SELECT InfoSiteMatchId, 
                      SubType, 
                      IsNoOffer
               FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, SubType INT, IsNoOffer BIT);

        -- Build log table
        INSERT INTO @Log
        (InfoSiteMatchId, 
         SubType, 
         IsNoOfferOld, 
         IsNoOfferNew
        )
               SELECT DISTINCT 
                      u.InfoSiteMatchId, 
                      u.SubType, 
                      1, 
                      0
               FROM [EventPickingNoOfferMatch] AS u WITH(NOLOCK)
                    INNER JOIN @Temp AS t ON u.InfoSiteMatchId = t.InfoSiteMatchId
               WHERE t.IsNoOffer = 0
                     AND t.InfoSiteMatchId = u.InfoSiteMatchId
                     AND ISNULL(u.SubType, 0) = ISNULL(t.SubType, 0);
        INSERT INTO @Log
        (InfoSiteMatchId, 
         SubType, 
         IsNoOfferOld, 
         IsNoOfferNew
        )
               SELECT DISTINCT 
                      t.InfoSiteMatchId, 
                      t.SubType, 
                      0, 
                      1
               FROM @Temp AS t
                    LEFT JOIN [EventPickingNoOfferMatch] AS um WITH(NOLOCK) ON t.InfoSiteMatchId = um.InfoSiteMatchId
                                                                               AND ISNULL(um.SubType, 0) = ISNULL(t.SubType, 0)
               WHERE t.IsNoOffer = 1
                     AND um.InfoSiteMatchId IS NULL;

        -- Delete match offer
        DELETE u
        FROM [EventPickingNoOfferMatch] AS u WITH(NOLOCK)
             INNER JOIN @Temp AS t ON u.InfoSiteMatchId = t.InfoSiteMatchId
        WHERE t.IsNoOffer = 0
              AND t.InfoSiteMatchId = u.InfoSiteMatchId
              AND ISNULL(u.SubType, 0) = ISNULL(t.SubType, 0);

        -- Insert new match is no offer
        INSERT INTO [EventPickingNoOfferMatch]
        ([InfoSiteMatchId], 
         SubType
        )
               SELECT t.InfoSiteMatchId,
                      CASE
                          WHEN t.SubType = 0
                          THEN NULL
                          ELSE t.SubType
                      END
               FROM @Temp AS t
                    LEFT JOIN [EventPickingNoOfferMatch] AS um WITH(NOLOCK) ON t.InfoSiteMatchId = um.InfoSiteMatchId
                                                                               AND ISNULL(um.SubType, 0) = ISNULL(t.SubType, 0)
               WHERE t.IsNoOffer = 1
                     AND um.InfoSiteMatchId IS NULL;

        -- Write log

        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);
        DECLARE @i INT, @rowMax INT;
        DECLARE @objectid INT;
        SELECT @rowMax = MAX(mm.id)
        FROM @Log AS mm;
        SET @i = 1;
        WHILE(@i <= @rowMax)
            BEGIN
                SET @XmlLogOld =
                (
                    SELECT slm.InfoSiteMatchId '@imid', 
                           slm.SubType '@st', 
                           slm.IsNoOfferOld '@iof'
                    FROM @Log AS slm
                    WHERE slm.id = @i FOR XML PATH('z'), ROOT('r')
                );

                SET @XmlLogNew =
                (
                    SELECT slm.InfoSiteMatchId '@imid', 
                           slm.SubType '@st', 
                           slm.IsNoOfferNew '@iof'
                    FROM @Log AS slm
                    WHERE slm.id = @i FOR XML PATH('z'), ROOT('r')
                );

                SELECT TOP 1 @objectid = slm.InfoSiteMatchId
                FROM @Log AS slm
                WHERE slm.id = @i;

                SET @LogNew = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogNew), '" />', '"/"');
                SET @LogOld = REPLACE(CONVERT(NVARCHAR(MAX), @XmlLogOld), '" />', '"/"');

                EXEC dbo.OWP_WriteLog 
                     @CreatorId = @ActorId, 
                     @SPName = 'OWP_EventPicking_InsertOrDeleteNoOfferMatch', 
                     @LoggedDate = @StartRun, 
                     @Duration = @Duration, 
                     @ObjectId = @objectid, 
                     @Data = @LogNew, 
                     @DataOld = @LogOld;
                SET @i = @i + 1;
            END;
    END;