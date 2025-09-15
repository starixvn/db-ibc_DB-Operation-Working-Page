
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

    -- Nếu bảng tạm đã tồn tại trong session thì drop
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
        DROP TABLE #Temp;

    -- Tạo bảng tạm
    CREATE TABLE #Temp
    (
        InfoSiteMatchId INT NOT NULL,
        ChildMatchId    INT,
        IsNoOffer       BIT
    );

    -- Insert dữ liệu từ JSON vào bảng tạm
    INSERT INTO #Temp (InfoSiteMatchId, ChildMatchId, IsNoOffer)
    SELECT InfoSiteMatchId, ChildMatchId, IsNoOffer
    FROM OPENJSON(@MatchInfoJson)
    WITH (
        InfoSiteMatchId INT,
        ChildMatchId    INT,
        IsNoOffer       BIT
    );

    -- MERGE dữ liệu
    MERGE dbo.EventPickingNoOfferMatch AS t
    USING #Temp AS s
       ON t.InfoSiteMatchId = s.InfoSiteMatchId
          AND ISNULL(t.ChildMatchId, 0) = ISNULL(s.ChildMatchId, 0)
    WHEN MATCHED THEN
        UPDATE SET 
            t.IsNoOffer   = s.IsNoOffer,
            t.UpdatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (InfoSiteMatchId, ChildMatchId, CreatedDate)
        VALUES (s.InfoSiteMatchId,
                CASE WHEN s.ChildMatchId = 0 THEN NULL ELSE s.ChildMatchId END,
                GETDATE());

	--write log

	select * from #Temp
	DECLARE @NowUTC8 DATETIME = DATEADD(HOUR, 8, GETUTCDATE());
	INSERT INTO EventPickingLog
	(
		[Date], 
		InfositeId, 
		[UpdateTypeId],
		ModifiedBy, 
		[Action], 
		OldValue, 
		NewValue
	)
	SELECT 
		@NowUTC8, 
		t.InfoSiteMatchId, 
		63,
		(SELECT [Username] FROM dbo.[User] WHERE [UserId] = @ActorId),
		'Update the <strong>Match Offer</strong>',
		CASE t.IsNoOffer WHEN 1 THEN 'Offer' ELSE 'No Offer' END,
		CASE t.IsNoOffer WHEN 1 THEN 'No Offer' ELSE 'Offer' END
	FROM #Temp AS t;

END