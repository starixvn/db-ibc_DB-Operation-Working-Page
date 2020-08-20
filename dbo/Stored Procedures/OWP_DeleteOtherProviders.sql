
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_DeleteOtherProviders] @Ids NVARCHAR(MAX)
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
     DECLARE @tempIds TABLE(Id INT);
     INSERT INTO @tempIds(Id)
            SELECT DISTINCT 
                   val
            FROM fnc_SplitStrings(@Ids, ',') u OPTION(MAXRECURSION 0);
     DECLARE @RemainFlag BIT;
     SELECT @RemainFlag = 1;
     WHILE @RemainFlag = 1
         BEGIN
             DELETE TOP (3000)
             o
             FROM dbo.[OtherProvider] o WITH(ROWLOCK)
                  INNER JOIN @tempIds i ON o.OtherProviderId = i.Id;
             IF @@ROWCOUNT = 0
                 SELECT @RemainFlag = 0;
         END;