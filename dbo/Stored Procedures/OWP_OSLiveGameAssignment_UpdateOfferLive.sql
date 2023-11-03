
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_OSLiveGameAssignment_UpdateOfferLive] @XML NVARCHAR(MAX)
AS

/*      
 Created: 20231102@Liam
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20231102@Liam: update os offerlive - [Redmine: #195697]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @idoc INT;
        DECLARE @tblOfferLive TABLE
        (OSMatchId    INT, 
         NewOfferLive VARCHAR(15)
        );
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        INSERT INTO @tblOfferLive
        (OSMatchId, 
         NewOfferLive
        )
               SELECT [OSMatchId], 
                      [NewOfferLive]
               FROM OPENXML(@idoc, '/Root/OfferLiveInfo', 1) WITH([OSMatchId] INT, [NewOfferLive] VARCHAR(15));
        EXEC sp_xml_removedocument 
             @idoc;
        UPDATE o
          SET 
              OfferLiveStatus = tbl.NewOfferLive
        FROM OSMatch o WITH(NOLOCK)
             INNER JOIN @tblOfferLive tbl ON o.OSMatchId = tbl.OSMatchId;
    END;