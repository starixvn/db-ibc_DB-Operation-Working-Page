/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchDiscussion_GetInfo] @AdminSiteMatchId INT
AS
/*  
Created: 20251105@Hank  
Task : Query discussion info
DB: bodb_OWP  
  
Revisions:  
 20251105@Hank: query discussion info  - [Redmine: #240618]  
 20251113@Hank: add CreatedBy column
*/
BEGIN
    SET NOCOUNT ON;
    SELECT info.[DiscussionId], 
            info.[AdminSiteMatchId], 
            info.[BetType], 
            info.[RCDiscussionGroupId], 
            info.[BetOn], 
            info.[HomeId], 
            info.[AwayId], 
            info.[GhostName], 
            info.[GhostDetail], 
            info.[HdpOu], 
            info.[Odds], 
            info.[Note], 
            info.[Remark],
            discussion.CreatedBy
    FROM [dbo].[PreMatchDiscussionInfo] as info WITH(NOLOCK)
    INNER JOIN [dbo].[PreMatchDiscussion]  as discussion WITH(NOLOCK) ON [info].[DiscussionId] = [discussion].[Id]
    WHERE info.[AdminSiteMatchId] = @AdminSiteMatchId;

        SELECT om.AdminSiteMatchId AS AdminSiteMatchId,
               om.LeagueName,
               om.HomeName,
               om.OWPHomeId as HomeId,
               om.AwayName,
               om.OWPAwayId as AwayId
        FROM dbo.InfoSiteMatch AS om WITH(NOLOCK)
        WHERE om.AdminSiteMatchId = @AdminSiteMatchId;
END