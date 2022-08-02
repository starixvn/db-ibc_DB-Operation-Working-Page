
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE OWP_OSLeagueSetting_GetStatusOption
AS

/*
Created: 20220701@Carlos
Task : Get OS league status option
DB: bodb_OWP

Revisions:
	20220701@Carlos: Initial - [Redmine: #174431]
	
*/

    BEGIN
        SET NOCOUNT ON;
       SELECT Id AS [value],
	   [label] FROM OSStatusOption
    END;