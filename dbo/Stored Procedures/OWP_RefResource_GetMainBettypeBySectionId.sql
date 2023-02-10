USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_RefResource_GetMainBettypeBySectionId]    Script Date: 12/04/2020 13:20:24 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_RefResource_GetMainBettypeBySectionId] @SectionId INT = NULL
AS

/*
Created: 20230209@Carlos.nguyen
Task : Get refresource by sectionId
DB: bodb_OWP	

Revisions:
	20230209@Carlos.nguyen: Get refresource by sectionId - [Redmine: #183243]
	*/

    BEGIN
        SET NOCOUNT ON;
        IF @SectionId IS NULL
            BEGIN
                SELECT r.RefName AS [Name], 
                       s.BettypeId AS ResourceId, 
                       r.Value
                FROM dbo.RefResource r WITH(NOLOCK)
                     INNER JOIN dbo.SectionBetTypePreferencesDefault s WITH(NOLOCK) ON r.RefName = 'BetTypePreferences'
                                                                                       AND r.ResourceId = s.BettypeId
                ORDER BY s.[Order] ASC;
        END;
            ELSE
            BEGIN
                SELECT r.RefName AS [Name],
                        s.BettypeId AS ResourceId, 
                       r1.Value
                FROM dbo.RefResource r WITH(NOLOCK)
                     INNER JOIN dbo.SectionBetTypePreferences s WITH(NOLOCK) ON r.RefName = 'Section'
                                                                                AND r.ResourceId = s.[SectionId]
                     INNER JOIN dbo.RefResource r1 WITH(NOLOCK) ON r1.RefName = 'BetTypePreferences'
                                                                   AND r1.ResourceId = s.BettypeId
                WHERE r.ResourceId = @SectionId
                ORDER BY s.[Order] ASC;
        END;
    END;