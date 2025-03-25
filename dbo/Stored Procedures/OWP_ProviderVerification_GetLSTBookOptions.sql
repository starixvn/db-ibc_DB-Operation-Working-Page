/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_ProviderVerification_GetLSTBookOptions] @EventDate DATE
AS

/*
Created: 20250318@Lilac
Task : Provider verification
DB: bodb_OWP

Revisions:
	20250318@Lilac: Get lst book provider option - [Redmine: #213719]
*/

     DECLARE @FromDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, 0, @EventDate), '12:00:00');
     DECLARE @ToDate DATETIME= DATEADD(DAY, DATEDIFF(DAY, -1, @EventDate), '11:59:59');

    BEGIN
        SET NOCOUNT ON;

		SELECT DISTINCT
			rs.ProviderId AS LSTBookId,
			rs.ProviderName AS LSTBookName
		FROM dbo.OWPMatch AS om WITH(NOLOCK)
		LEFT JOIN dbo.MatchProvider AS mp WITH(NOLOCK) ON om.OWPMatchId = mp.OWPMatchId
		INNER JOIN dbo.[Provider] AS rs WITH(NOLOCK) ON rs.ProviderId = mp.ProviderId
		WHERE om.EventDateTime BETWEEN @FromDate AND @ToDate;

    END;