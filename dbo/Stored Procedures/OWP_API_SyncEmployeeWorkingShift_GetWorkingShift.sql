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
*/
	SET NOCOUNT ON;
    SELECT ew.EmployeeId
		, ew.ShiftDate
		, UPPER(sc.ShiftCode) AS ShiftCode
		, ew.ShiftStartTime
		, ew.ShiftEndTime
		, ew.LastUpdated
		, IsTimeShift
		, Extension
    FROM EmployeeWorkingShift AS ew WITH (NOLOCK)
    LEFT JOIN EmployeeWorkingShiftColor AS sc ON ew.ShiftId= sc.ShiftId
    WHERE ew.ShiftDate BETWEEN  @FromDate AND @ToDate