
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_EventPicking_InsertOrUpdateNoOfferMatch] @MatchInfoJson NVARCHAR(MAX), 
                                                                  @ActorId       INT

/*
Created: 20221027@Carlos.nguyen
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20250911@los: Event picking auto mark no offer  [Redmine: #236469]
*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (InfoSiteMatchId INT NOT NULL, 
         ChildMatchId    INT, 
         IsNoOffer       BIT
        );
        INSERT INTO @Temp
        (InfoSiteMatchId, 
         ChildMatchId, 
         IsNoOffer
        )
               SELECT InfoSiteMatchId, 
                      ChildMatchId, 
                      IsNoOffer
               FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, ChildMatchId INT, IsNoOffer BIT);
        MERGE [EventPickingNoOfferMatch] AS t
        USING @Temp AS s
        ON t.InfoSiteMatchId = s.InfoSiteMatchId
           AND ISNULL(t.ChildMatchId, 0) = ISNULL(s.ChildMatchId, 0)
            WHEN MATCHED
            THEN UPDATE SET 
                            t.[IsNoOffer] = s.IsNoOffer, 
                            t.UpdatedDate = GETDATE()
            WHEN NOT MATCHED
            THEN
              INSERT([InfoSiteMatchId],
                     ChildMatchId, 
                     CreatedDate)
              VALUES
        (s.InfoSiteMatchId,
         CASE
             WHEN s.ChildMatchId = 0
             THEN NULL
             ELSE s.ChildMatchId
         END, 
         GETDATE()
        );
    END;