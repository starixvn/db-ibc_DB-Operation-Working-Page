
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROC [dbo].[OWP_OSLeagueSetting_GetBetTypesOption]
AS

/*
Created: 20220707@Luca
Task : Get OS league bettype option
DB: bodb_OWP

Revisions:
	20220707@Luca: Initial - [Redmine: #174431]

*/

    BEGIN
        SET NOCOUNT ON;
        SELECT Id AS [value], 
               [label]
        FROM OSBettypeOption;
    END;