USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_TicketCenterEvent_Get]    Script Date: 09/23/2021 11:18:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
ALTER PROCEDURE[dbo].[OWP_TicketCenterEvent_Get] @ActorId INT,
	@Keyword NVARCHAR(255) = NULL,
	@TicketId NVARCHAR(255) = NULL,
	@TicketTypeId INT = 0,
	@MarketKey INT=1
AS
/*      
 ALTERd: 20210917@Carlos.Nguyen
 Task : New ticket issue event
 DB: bodb_OWP      
      
 Revisions:          
	20210917@Carlos.Nguyen: Event ticket - [Redmine: #158037]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblTicketRecipient TABLE (TicketId INT)
	DECLARE @allTicketTypeId INT=0
	DECLARE @allMarketKey INT=1
	DECLARE @earlyMarketKey INT=2
	DECLARE @todayMarketKey INT=3
	DECLARE @earlyFilter INT= 2 
	DECLARE @fromDate DATETIME
	DECLARE @toDate DATETIME;
	
	IF @MarketKey = @earlyMarketKey
    BEGIN
		SET @fromDate= DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), '12:00:00');
	END
	
	IF @MarketKey = @todayMarketKey
    BEGIN
        SET @fromDate= DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), '12:00:00');
        SET @toDate = DATEADD(DAY, DATEDIFF(DAY, -1, @fromDate), '11:59:59')
    END;
    
	INSERT INTO @tblTicketRecipient
	EXEC [dbo].[OWP_TicketCenter_GetTicketIdByRecipientId] @ActorId=@ActorId
	
	SELECT tbltk.TicketId,
	 owpl.OWPLeagueId,
	 owpl.OWPLeagueName,
	 tl.OwpHomeId,
	 tl.OwpAwayId,
	 ifm.HomeName,
	 ifm.AwayName,
	 tis.TicketType,
	 ty.TypeName,
	 tm.UserId,
	 tm.CreatedDate,
	 tm.[Message],
	 ifm.EventDateTime AS KOTime,
	 CASE WHEN u.Nickname IS NULL
		THEN u.Username
		ELSE u.Nickname
	 END AS Username
	FROM TicketIssue AS tis WITH (NOLOCK)
		INNER JOIN @tblTicketRecipient AS tbltk ON tbltk.TicketId=tis.TicketId
		INNER JOIN TicketType AS ty WITH (NOLOCK)ON tis.TicketType=ty.TypeId 
		INNER JOIN TicketIssueEvent AS tl WITH (NOLOCK) ON tis.TicketId=tl.TicketId
		INNER JOIN InfoSiteMatch AS ifm ON ifm.OWPHomeId=tl.OwpHomeId AND ifm.OWPAwayId=tl.OwpAwayId AND tl.OwpLeagueId=ifm.OWPLeagueId
		INNER JOIN TicketMessage AS tm WITH (NOLOCK)ON tis.TicketId=tm.TicketId
		INNER JOIN OWPLeague AS owpl WITH (NOLOCK) ON owpl.OWPLeagueId=tl.OwpLeagueId
		INNER JOIN [User] AS u WITH (NOLOCk) ON tm.UserId=u.UserId
	WHERE (@Keyword IS NULL OR
		@Keyword ='' OR
		owpl.OWPLeagueName LIKE '%'+@Keyword+'%' OR
		ifm.HomeName LIKE '%'+@Keyword+'%' OR
		ifm.AwayName LIKE '%'+@Keyword+'%')
		AND
		(
			@TicketId IS NULL OR
			@TicketId ='' OR
			CONVERT(VARCHAR(255), tbltk.TicketId) LIKE @TicketId+'%'
		)AND
		(
			@TicketTypeId=@allTicketTypeId OR
			tis.TicketType = @TicketTypeId
		) AND
		 (
			@MarketKey = @allMarketKey OR
			(@MarketKey = @earlyMarketKey AND ifm.EventDateTime>=@fromDate)OR
			(@MarketKey = @todayMarketKey AND ifm.EventDateTime BETWEEN @fromDate AND @toDate)
		 )
END