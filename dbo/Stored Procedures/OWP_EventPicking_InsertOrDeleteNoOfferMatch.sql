
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
         SubType         INT, 
         IsNoOffer       BIT
        );
        DECLARE @NewMatch TABLE
        (InfoSiteMatchId INT NOT NULL, 
         SubType         INT
        );
        INSERT INTO @Temp
        (InfoSiteMatchId, 
         SubType, 
         IsNoOffer
        )
               SELECT InfoSiteMatchId, 
                      SubType, 
                      IsNoOffer
               FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, SubType INT, IsNoOffer BIT);

        -- Delete match offer
        DELETE u
        FROM [EventPickingNoOfferMatch] u
             INNER JOIN @Temp AS t ON u.InfoSiteMatchId = t.InfoSiteMatchId
        WHERE t.IsNoOffer = 0
              AND t.InfoSiteMatchId = u.InfoSiteMatchId
              AND ISNULL(u.SubType, 0) = ISNULL(t.SubType, 0);

        -- Insert new match un offer

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
    END;