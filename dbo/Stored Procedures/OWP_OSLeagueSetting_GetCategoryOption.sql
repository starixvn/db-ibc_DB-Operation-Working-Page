
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_GetCategoryOption
AS

/*
Created: 20220701@Carlos
Task : Get OS league category option
DB: bodb_OWP

Revisions:
	20220701@Carlos: Initial - [Redmine: #174431]
	
*/

    BEGIN
        SET NOCOUNT ON;
       SELECT Id AS [value],
	   [label] FROM OSCategoryOption
    END;
