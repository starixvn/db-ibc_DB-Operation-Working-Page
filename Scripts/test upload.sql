/*
--test insert - profiler để lấy data XML cần insert
declare @SessionId varchar(50) = CAST(NEWID() AS varchar(50))
exec OWP_AssignmentUploading_Insert @SessionId=@SessionId,@UserId=8,@AssignmentUploadDoc=N'<Root>
  <Row EventDate="07/25/2018 00:00:00" RowNumber="3" MatchNo="no2" MatchStatus="Live" MatchId="" KickOffTime="04:00 PM" OtherTime="" MatchOffer="" LeagueName="League1" HomeName="Home1" AwayName="Away1" Round="" Division="" Remark="" Note="" MaxBetHDP="" SpreadHDP="" NoHDP="" TraderHDP="starix1" OtherTradersHDP="&lt;Root&gt;&#xD;&#xA;  &lt;r u=&quot;starix2&quot; n=&quot;#&amp;lt;user&amp;gt; hdp&quot; /&gt;&#xD;&#xA;  &lt;r u=&quot;&quot; n=&quot;abc&quot; /&gt;&#xD;&#xA;  &lt;r u=&quot;starix3&quot; n=&quot;xyz #&amp;lt;user&amp;gt;&quot; /&gt;&#xD;&#xA;&lt;/Root&gt;" MaxBet1HHDP="" Spread1HHDP="" Trader1HHDP="" OtherTraders1HHDP="" MaxBetOU="" SpreadOU="" TraderOU="" OtherTradersOU="" MaxBet1HOU="" Spread1HOU="" Trader1HOU="" OtherTraders1HOU="" MaxBet1X2="" Spread1X2="" Trader1X2="" OtherTraders1X2="" MaxBet1H1X2="" Spread1H1X2="" Trader1H1X2="" OtherTraders1H1X2="" MaxBetXMins="" SpreadXMins="" Trader15Mins="" OtherTraders15Mins="" Trader10Mins="" OtherTraders10Mins="" LA="" OtherLA="" MaxBetFM="" SpreadFM="" TraderFM="" OtherTradersFM="" TraderAIO="" OtherTradersAIO="" Agent="" TV="" Channel="" WatchBet="" Provider="" Runner="" Phone="" Website1="" Website2="" Website3="" Website4="" />
</Root>'

select * from dbo.AssignmentUploading where SessionId=@SessionId
select * from dbo.AssignmentUploadingOtherTrader where SessionId=@SessionId
select * from dbo.AssignmentUploadingLog where SessionId=@SessionId
*/

/*
--kiem tra data hien tai
declare @SessionId varchar(50)

select top 1 @SessionId = SessionId
from dbo.AssignmentUploadingLog
order by CreatedDate desc

select @SessionId

select * from dbo.AssignmentUploading where SessionId=@SessionId
select * from dbo.AssignmentUploadingOtherTrader where SessionId=@SessionId
select * from dbo.AssignmentUploadingLog where SessionId=@SessionId
*/

/*
-- test submit - de test cái này, phải chạy đến bước validate nhưng k bấm nút submit
declare @SessionId varchar(50)

select top 1 @SessionId = SessionId
from dbo.AssignmentUploadingLog
order by CreatedDate desc

select @SessionId

--delete a from Assignment as a inner join OWPMatch AS m on m.OWPMatchId = a.OWPMatchId where m.EventDate = CAST(DATEADD(hour, 4, GETDATE()) AS Date)
--delete m from OWPMatch AS m where m.EventDate = CAST(DATEADD(hour, 4, GETDATE()) AS Date)
--update mi set mi.MatchStatus = 'Cancel' from MatchInfo AS mi inner join OWPMatch AS m on m.OWPMatchId = mi.OWPMatchId where m.EventDate = CAST(DATEADD(hour, 4, GETDATE()) AS Date)

UPDATE dbo.AssignmentUploadingLog WITH (ROWLOCK, UPDLOCK)
	SET [Status] = 3
	WHERE SessionId = @SessionId
declare @ErrCode INT
	,@ErrMsg NVARCHAR(200)
exec OWP_AssignmentUploading_Submit @UserId=8,@SessionId=@SessionId,@ErrCode=@ErrCode output,@ErrMsg=@ErrMsg output
select @ErrCode, @ErrMsg
*/


--test after submit
declare @SessionId varchar(50)

select top 1 @SessionId = SessionId
from dbo.AssignmentUploadingLog
order by CreatedDate desc

select @SessionId

declare @EventDate Date
SELECT TOP 1 @EventDate = CASE 
	WHEN CAST(KickOffTime AS TIME) >= CAST('12:00:00' AS TIME) THEN EventDate
	ELSE DATEADD(DD, - 1, EventDate)
	END
FROM dbo.AssignmentUploading WITH (NOLOCK)
	WHERE SessionId = @SessionId

select @EventDate

declare @Match table  (
	OWPMatchId INT
)

insert into @Match
select OWPMatchId from OWPMatch
where (EventDate = @EventDate AND KickOffTime >= CAST('12:00:00' AS TIME))
	OR (EventDate = DATEADD(DD, 1, @EventDate) AND KickOffTime < CAST('12:00:00' AS TIME))

select om.*, mi.* from OWPMatch as om
inner join @Match as m on om.OWPMatchId = m.OWPMatchId
inner join dbo.MatchInfo as mi on mi.OWPMatchId = m.OWPMatchId

select mi.*, u.Username from Assignment as mi
inner join @Match as m on mi.OWPMatchId = m.OWPMatchId
left join dbo.[User] as u on mi.UserId = u.UserId

select mm.* from MinorMatch as mm
inner join @Match as m on mm.MinorMatchId = m.OWPMatchId

select top 10 * from [Message] as m
order by MessageId desc


--select mi.* from MatchInfo as mi
--inner join @Match as m
--on mi.OWPMatchId = m.OWPMatchId

--select mn.* from MatchNote as mn
--inner join @Match as m
--on mn.OWPMatchId = m.OWPMatchId
