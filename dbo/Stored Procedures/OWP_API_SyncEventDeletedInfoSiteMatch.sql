
CREATE PROCEDURE [dbo].[OWP_API_SyncEventDeletedInfoSiteMatch]
	/*    
 Created: 20190104@Kane.Le
 Task : Service Prevent sync deleted event 
 DB: bodb_OWP    
    
 Revisions:
	20190104@Kane.Le: Initial SP - [Redmine: #107257] 
*/
	@Ids NVARCHAR(MAX)
AS
BEGIN
	UPDATE dbo.InfoSiteMatch
	WITH (ROWLOCK)

	SET IsDeleted = 1
	WHERE InfoSiteMatchId IN (
			SELECT val
			FROM dbo.fnc_SplitStrings(@Ids, ',')
			)
	OPTION (MAXRECURSION 0)
END