USE [bodb_OWP];
GO

/****** Object:  StoredProcedure [dbo].[OWP_RefResource_GetLevelBySectionId]    Script Date: 12/04/2020 13:20:24 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_RefResource_GetLevelBySectionId] @SectionId INT = NULL
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
                       s.LevelId AS ResourceId, 
                       r.Value
                FROM dbo.RefResource r WITH(NOLOCK)
                     INNER JOIN dbo.SectionLevelDefault s WITH(NOLOCK) ON r.RefName = 'UserLevel'
                                                                          AND r.ResourceId = s.[LevelId]
                ORDER BY s.[Order] ASC;
        END;
            ELSE
            BEGIN
                SELECT r1.RefName AS [Name],
                        s.LevelId AS ResourceId,
                       r1.Value
                FROM dbo.RefResource r WITH(NOLOCK)
                     INNER JOIN dbo.SectionLevel s WITH(NOLOCK) ON r.RefName = 'Section'
                                                                   AND r.ResourceId = s.[SectionId]
                     INNER JOIN dbo.RefResource r1 WITH(NOLOCK) ON r1.RefName = 'UserLevel'
                                                                   AND r1.ResourceId = s.LevelId
                WHERE r.ResourceId = @SectionId
                ORDER BY s.[Order] ASC;
        END;
    END;