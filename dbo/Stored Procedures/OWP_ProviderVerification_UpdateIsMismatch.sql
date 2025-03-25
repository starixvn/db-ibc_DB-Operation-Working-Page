/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_UpdateIsMismatch] @EventDate DATE,
																	@OwpMatchIds NVARCHAR(Max) = NULL,
																	@ActorId    INT
AS

/*
Created: 20250312@Lilac
Task : Provider verification
DB: bodb_OWP

Revisions:
	20250312@Lilac: update mismatch - [Redmine: #213719]
*/

BEGIN
    SET NOCOUNT ON;

    DECLARE @FromDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
    DECLARE @ToDate DATETIME = DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');

	DECLARE @PayloadTable TABLE (LogMessage NVARCHAR(MAX));
	DECLARE @PayloadLog NVARCHAR(MAX) = '';
	DECLARE @Now DATETIME = DATEADD(HOUR, 12, GETDATE());
    DECLARE @tblRefResourceMatchId TABLE (Id INT NOT NULL);

	IF @OwpMatchIds IS NOT NULL
	BEGIN
		INSERT INTO @tblRefResourceMatchId (Id)
		SELECT CAST(value AS INT) FROM STRING_SPLIT(@OwpMatchIds, ',');
	END

	INSERT INTO ProviderVerification (OWPMatchId, IsMismatchEvent)
    SELECT tr.Id, 0
    FROM @tblRefResourceMatchId tr
    WHERE NOT EXISTS (
        SELECT 1 FROM ProviderVerification pv WHERE pv.OWPMatchId = tr.Id
    );

	UPDATE pv WITH(ROWLOCK)
    SET pv.IsMismatchEvent = 1
	OUTPUT '{OWPMatchId: ' + CAST(inserted.OWPMatchId AS NVARCHAR) + ', IsMismatchEvent: true}, ' 
       INTO @PayloadTable (LogMessage)
    FROM ProviderVerification pv
    INNER JOIN @tblRefResourceMatchId tr ON pv.OWPMatchId = tr.Id;

	UPDATE pv WITH(ROWLOCK)
    SET pv.IsMismatchEvent = 0
	OUTPUT '{OWPMatchId: ' + CAST(inserted.OWPMatchId AS NVARCHAR) + ', IsMismatchEvent: false}, ' 
       INTO @PayloadTable (LogMessage)
    FROM ProviderVerification pv
    WHERE NOT EXISTS (
        SELECT 1 FROM @tblRefResourceMatchId tr WHERE pv.OWPMatchId = tr.Id
    )
    AND EXISTS (
        SELECT 1 FROM dbo.OWPMatch om WITH(NOLOCK)
        WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate
        AND pv.OWPMatchId = om.OWPMatchId
    );

	SELECT @PayloadLog = 
		'{ "CreatorId": ' + CAST(@ActorId AS NVARCHAR) + ', "Data": ' +
		CASE 
			WHEN COUNT(*) = 0 THEN '[]' 
			ELSE '[' + STRING_AGG(LogMessage, ', ') + ']' 
		END + '}'
	FROM @PayloadTable;

	EXEC dbo.OWP_InternalSystem_WriteLog 
	@CreatedDate = @Now, 
	@Action = 'ProviderVerification-UpdateIsMismatchEvent', 
	@Payload = @PayloadLog;

END