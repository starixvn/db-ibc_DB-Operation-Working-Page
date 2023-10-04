
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE OWP_OSLeagueSetting_GetBetDelayOption
AS

/*
Created: 20220804@Carlos
Task : Get OS league bet delay option
DB: bodb_OWP

Revisions:
	20220804@Carlos: Initial - [Redmine: #175994]
	20230310@Mira: Sort betday - [Redmine: #194449]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT Id AS [value], 
               [label]
        FROM OSBetDelayOption
        ORDER BY [Order];
    END;