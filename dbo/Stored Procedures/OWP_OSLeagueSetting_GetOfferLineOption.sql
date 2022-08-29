
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE OWP_OSLeagueSetting_GetOfferLineOption
AS

/*
Created: 20220804@Carlos
Task : Get OS league offer line option
DB: bodb_OWP

Revisions:
	20220804@Carlos: Initial - [Redmine: #175994]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT Id AS [value], 
               [label]
        FROM OSOfferLineOption;
    END;