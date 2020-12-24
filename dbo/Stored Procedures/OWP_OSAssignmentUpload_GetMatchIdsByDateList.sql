USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_OSAssignmentUpload_GetMatchIdsByDateList]    Script Date: 12/24/2020 11:09:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_OSAssignmentUpload_GetMatchIdsByDateList] @EventDates NVARCHAR(MAX)
AS

/*
Created: 20201224@Jack
Task : Other Sport
DB: bodb_OWP

Revisions:
	20201224@Jack: Init SP [Redmine: #146962]
*/

    BEGIN
        CREATE TABLE #tmpTable(EvenDates DATE);
        INSERT INTO #tmpTable
               SELECT DISTINCT 
                      val
               FROM fnc_SplitStrings(@EventDates, ',') u OPTION(MAXRECURSION 0);

		--Select OSMatchId
        SELECT dbo.OSMatch.OSMatchId
        FROM dbo.OSMatch
        WHERE dbo.OSMatch.EventDate IN
        (
            SELECT EvenDates
            FROM #tmpTable
        );
        DROP TABLE #tmpTable;
    END;

