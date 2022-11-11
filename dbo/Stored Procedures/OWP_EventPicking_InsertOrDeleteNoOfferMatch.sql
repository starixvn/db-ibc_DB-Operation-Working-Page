
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_EventPicking_InsertOrDeleteNoOfferMatch] @MatchInfoJson NVARCHAR(MAX)

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
         MinorBettypeId  INT, 
         IsNoOffer       BIT
        );
        DECLARE @NewMatch TABLE
        (InfoSiteMatchId INT NOT NULL, 
         MinorBettypeId  INT
        );
        INSERT INTO @Temp
        (InfoSiteMatchId, 
         MinorBettypeId, 
         IsNoOffer
        )
               SELECT InfoSiteMatchId, 
                      MinorBettypeId, 
                      IsNoOffer
               FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, MinorBettypeId INT, IsNoOffer BIT);

        -- Delete match offer
        DELETE u
        FROM [EventPickingNoOfferMatch] u
             INNER JOIN @Temp AS t ON u.InfoSiteMatchId = t.InfoSiteMatchId
        WHERE t.IsNoOffer = 0
              AND t.InfoSiteMatchId = u.InfoSiteMatchId
              AND ISNULL(u.MinorBettypeId, 0) = ISNULL(t.MinorBettypeId, 0);

        -- Insert new match un offer

        INSERT INTO [EventPickingNoOfferMatch]
        ([InfoSiteMatchId], 
         [MinorBettypeId]
        )
               SELECT t.InfoSiteMatchId,
                      CASE
                          WHEN t.MinorBettypeId = 0
                          THEN NULL
                          ELSE t.MinorBettypeId
                      END
               FROM @Temp AS t
                    LEFT JOIN [EventPickingNoOfferMatch] AS um WITH(NOLOCK) ON t.InfoSiteMatchId = um.InfoSiteMatchId
                                                                               AND ISNULL(um.MinorBettypeId, 0) = ISNULL(t.MinorBettypeId, 0)
               WHERE t.IsNoOffer = 1
                     AND um.InfoSiteMatchId IS NULL;
    END;