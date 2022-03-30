/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_AutoAssignment_GetInfoSiteMatchResultByRequestId] @RequestId NVARCHAR(200)
AS

/*  
Created: 20220329@Johnny.Thai  
Task : Get Match Info By RequestID
DB: bodb_OWP  
  
Revisions:  
 20220329@Johnny.Thai : Get Match Info By RequestID - [Redmine: #166030]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT i.Bettype, 
               i.ExtraTime, 
               i.[Group], 
               i.InfoSiteMatchId, 
               i.IsFutsal, 
               i.IsSaba, 
               i.PcCode, 
               i.RequestId, 
               i.StatusCode, 
               i.UserId_1HHDP, 
               i.UserId_1HOU, 
               i.UserId_FTHDP, 
               i.UserId_FTOU, 
               i.UserId_LA
        FROM InfoSiteAutoAssignmentResult AS i
        WHERE i.RequestId = @RequestId;
    END;