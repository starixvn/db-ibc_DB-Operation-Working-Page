USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_API_SyncEmployeeWorkingShift_GetWorkingShift]    Script Date: 06/08/2021 14:43:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_API_SyncEmployeeWorkingShift_GetWorkingShift]
@FromDate DATE,
@ToDate DATE
AS

/*
Created: 20210608@Carlos.nguyen
Task : API sync Working Shifts to HRM
DB: bodb_OWP

Revisions:
	20210608@Carlos.nguyen: API sync Working Shifts to HRM - [Redmine: #156338]	
	20211008@Tyler: Update emp id - [Redmine: #162852]	
	20211228@Carlos: Support sync OT shift to HRM - [Redmine: #166487]
*/
	SET NOCOUNT ON;
    SELECT u.EmployeeId
		, ew.ShiftDate
		, UPPER(sc.ShiftCode) AS ShiftCode
		, ew.ShiftStartTime
		, ew.ShiftEndTime
		, ew.LastUpdated
		, IsTimeShift
		, sc.Extension
		,CASE WHEN ew.RefShiftId=190 THEN 'OFF'
			WHEN ew.RefShiftId=192 THEN 'PH'
			ELSE NULL
			END AS ShiftOT
    FROM EmployeeWorkingShift AS ew WITH (NOLOCK)
    INNER JOIN [User] AS u WITH (NOLOCK) ON u.UserId=ew.EmployeeId
    INNER JOIN EmployeeWorkingShiftPublish AS ewp WITH (NOLOCK) ON ew.ShiftDate BETWEEN ewp.FromDate AND ewp.ToDate AND ewp.SectionId=u.SectionId
    LEFT JOIN EmployeeWorkingShiftColor AS sc ON ew.ShiftId= sc.ShiftId
    WHERE ew.ShiftDate BETWEEN  @FromDate AND @ToDate AND ewp.IsPublished=1