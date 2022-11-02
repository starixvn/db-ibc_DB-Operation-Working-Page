
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_UnselectedMatch_InsertOrDelete] @MatchInfoJson NVARCHAR(MAX)

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
		 UnSelected			 BIT
        );

		DECLARE @NewMatch TABLE
		(InfoSiteMatchId	 INT NOT NULL, 
         AdminSiteMatchId      INT
		 )

        INSERT INTO @Temp
        (InfoSiteMatchId, 
         AdminSiteMatchId,
		 UnSelected
        )
        SELECT InfoSiteMatchId,
			AdminSiteMatchId,
			UnSelected
        FROM OPENJSON(@MatchInfoJson) WITH(InfoSiteMatchId INT, AdminSiteMatchId INT, UnSelected BIT);

		-- Delete match offer
		DELETE u
		FROM UnselectedMatch u
		INNER JOIN @Temp AS t ON u.InfoSiteMatchId=t.InfoSiteMatchId
		WHERE t.UnSelected=0

		-- Insert new match un offer
		
        INSERT INTO UnselectedMatch ([InfoSiteMatchId],[AdminSiteMatchId])
		SELECT t.InfoSiteMatchId,
			CASE WHEN t.AdminSiteMatchId=0 THEN NULL ELSE t.AdminSiteMatchId END
		FROM @Temp AS t LEFT JOIN UnselectedMatch AS um WITH (NOLOCK) ON
			t.InfoSiteMatchId= um.InfoSiteMatchId AND ISNULL(um.AdminSiteMatchId, -1)=ISNULL(t.AdminSiteMatchId, -1)
		WHERE t.UnSelected=1 AND um.InfoSiteMatchId IS NULL
        
    END;