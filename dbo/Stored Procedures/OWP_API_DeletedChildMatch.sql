
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE dbo.[OWP_API_DeletedChildMatch] @ChildMatchesJson NVARCHAR(MAX)

/*
Created: 20221027@Carlos.nguyen
Task : Event Picking New
DB: bodb_OWP	

Revisions:
	20201020@Carlos.nguyen: delete child matches from Infosite - Redmine: #179302
*/

AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Temp TABLE
        (InfoSiteMatchId  INT NOT NULL, 
         SubType          INT NOT NULL, 
         AdminSiteMatchId INT
        );
        INSERT INTO @Temp
        (InfoSiteMatchId, 
         SubType, 
         AdminSiteMatchId
        )
               SELECT InfoSiteMatchId, 
                      SubType, 
                      AdminSiteMatchId
               FROM OPENJSON(@ChildMatchesJson) WITH(InfoSiteMatchId INT, SubType INT, AdminSiteMatchId INT);

        --- Remove child match is deleted

        DELETE u
        FROM dbo.InfoSiteChildMatch AS u WITH(NOLOCK)
             INNER JOIN @Temp AS t ON u.ParentInfoSiteMatchId = t.InfoSiteMatchId
                                      AND u.SubType = t.SubType
                                      AND u.AdminSiteMatchId = t.AdminSiteMatchId;
        DELETE n
        FROM dbo.EventPickingNoOfferMatch AS n WITH(NOLOCK)
             LEFT JOIN dbo.InfoSiteChildMatch AS u WITH(NOLOCK) ON n.ChildMatchId = u.ChildMatchId
        WHERE u.ChildMatchId IS NULL;
    END;