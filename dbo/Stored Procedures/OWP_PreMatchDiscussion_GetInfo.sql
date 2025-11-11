/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchDiscussion_GetInfo] @AdminSiteMatchId INT
AS
/*  
Created: 20251105@Hank  
Task : Query discussion info
DB: bodb_OWP  
  
Revisions:  
 20251105@Hank: query discussion info  - [Redmine: #240618]  
*/
BEGIN
    SET NOCOUNT ON;
    SELECT [DiscussionId], 
            [AdminSiteMatchId], 
            [BetType], 
            [RCDiscussionGroupId], 
            [BetOn], 
            [HomeId], 
            [AwayId], 
            [GhostName], 
            [GhostDetail], 
            [HdpOu], 
            [Odds], 
            [Note], 
            [Remark]
    FROM [dbo].[PreMatchDiscussionInfo] WITH(NOLOCK)
    WHERE [AdminSiteMatchId] = @AdminSiteMatchId;

        SELECT om.AdminSiteMatchId AS AdminSiteMatchId,
               om.LeagueName,
               om.HomeName,
               om.OWPHomeId as HomeId,
               om.AwayName,
               om.OWPAwayId as AwayId
        FROM dbo.InfoSiteMatch AS om WITH(NOLOCK)
        WHERE om.AdminSiteMatchId = @AdminSiteMatchId;
END