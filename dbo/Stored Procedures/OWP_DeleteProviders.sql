
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteProviders] @Ids NVARCHAR(MAX)
AS

/*
	Created: Jacob
	Date: 2020-02-28
	Task: Clean Old Data
	DB: DBOWP/bodb_OWP
Revisions:
	20200817@Mira: Archive plan for OWP tables - [Redmine: #137757]	
Remarks:

*/

     SET NOCOUNT ON;
	 

     SET NOCOUNT ON;
     DECLARE @tempIds TABLE(Id INT);
     INSERT INTO @tempIds(Id)
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Ids, ',') u OPTION(MAXRECURSION 0);
     
	 DELETE o
	 FROM dbo.[Provider] o WITH(ROWLOCK)
		  INNER JOIN @tempIds i ON o.ProviderId = i.Id;
             