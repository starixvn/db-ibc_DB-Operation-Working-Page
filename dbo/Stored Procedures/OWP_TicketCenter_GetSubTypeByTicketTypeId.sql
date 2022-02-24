/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_TicketCenter_GetSubTypeByTicketTypeId] @TicketTypeId INT
AS

/*      
 Created: 20220221@Johnny.Thai
 Task : Get Subtype
 DB: bodb_OWP      
      
 Revisions:          
	20220221@Johnny.Thai: Get Subtype - [Redmine: #158037]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT ts.SubtypeId AS SubTypeId, 
               ts.SubtypeName AS SubTypeName
        FROM TicketSubtype AS ts
        WHERE ts.TypeId = @TicketTypeId;
    END;