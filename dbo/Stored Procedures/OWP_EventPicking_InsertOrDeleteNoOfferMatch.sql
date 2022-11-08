
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
        (InfoSiteMatchId	 INT NOT NULL, 
         AdminSiteMatchId      INT,
		 IsNoOffer			 BIT
        );

		DECLARE @NewMatch TABLE
		(InfoSiteMatchId	 INT NOT NULL, 
         AdminSiteMatchId      INT
		 )

        INSERT INTO @Temp
        (InfoSiteMatchId, 
         AdminSiteMatchId,
		 IsNoOffer
        )
        SELECT InfoSiteMatchId,
			AdminSiteMatchId,
			IsNoOffer
        FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, AdminSiteMatchId INT, IsNoOffer BIT);

		
		-- Delete match offer
		DELETE u
		FROM [EventPickingNoOfferMatch] u
		INNER JOIN @Temp AS t ON u.InfoSiteMatchId=t.InfoSiteMatchId
		WHERE t.IsNoOffer=0 AND t.InfoSiteMatchId= u.InfoSiteMatchId AND ISNULL(u.AdminSiteMatchId, 0)=ISNULL(t.AdminSiteMatchId, 0)

		-- Insert new match un offer
		
        INSERT INTO [EventPickingNoOfferMatch] ([InfoSiteMatchId],[AdminSiteMatchId])
		SELECT t.InfoSiteMatchId,
			CASE WHEN t.AdminSiteMatchId=0 THEN NULL ELSE t.AdminSiteMatchId END
		FROM @Temp AS t LEFT JOIN [EventPickingNoOfferMatch] AS um WITH (NOLOCK) ON
			t.InfoSiteMatchId= um.InfoSiteMatchId AND ISNULL(um.AdminSiteMatchId, 0)=ISNULL(t.AdminSiteMatchId, 0)
		WHERE t.IsNoOffer=1 AND um.InfoSiteMatchId IS NULL
        
    END;