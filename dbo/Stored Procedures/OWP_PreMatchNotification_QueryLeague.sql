USE [bodb_OWP];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_PreMatchNotification_QueryLeague] @FromDate DATE, 
                                                             @ToDate   DATE
AS

/*  
Created: 20210610@Tyler.Dang  
Task : Query league
DB: bodb_OWP  
  
Revisions:  
 20210610@Tyler.Dang: query league  - [Redmine: #156321]  
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT [PreMatchLeagueId], 
               pl.[OWPLeagueId], 
               [EventDate], 
               [IsDay], 
               ol.[OWPLeagueName]
        FROM [dbo].[PreMatchLeague] pl WITH(NOLOCK)
             INNER JOIN [dbo].[OWPLeague] ol WITH(NOLOCK) ON ol.OWPLeagueId = pl.OWPLeagueId
        WHERE pl.EventDate >= @FromDate
              AND pl.EventDate <= @ToDate;
    END;