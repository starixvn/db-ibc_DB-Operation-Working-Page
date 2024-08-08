USE [bodb_OWP]
GO
/****** Object:  StoredProcedure [dbo].[OWP_NewLeagueSetting_RemoveLeagueSetting]    Script Date: 8/5/2024 1:50:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_NewLeague_Update_Condition] @XML NVARCHAR(MAX)
                                                                
AS

/*      
 Created: 20240801@Los
 Task : Init sp
 DB: bodb_OWP      
 
 Revisions:
    20240801@Los: Update condition   - [Redmine: #207941]

*/

    BEGIN
        SET NOCOUNT ON;
		DECLARE @idoc INT;
        EXEC sp_xml_preparedocument 
             @idoc OUTPUT, 
             @XML;
        CREATE TABLE #tblLeague
        (
         League                   NVARCHAR(200) NOT NULL, 
         FullConditionDescription NVARCHAR(MAX)
        );
        INSERT INTO #tblLeague
        (League, 
         FullConditionDescription
        )
               SELECT 
                      [League], 
                      [FullConditionDescription]
               FROM OPENXML(@idoc, '/Root/UpdateCondition', 1) WITH(
			   [League] NVARCHAR(200),
			   [FullConditionDescription] NVARCHAR(MAX));
        EXEC sp_xml_removedocument 
             @idoc;
		
		UPDATE setting
		SET setting.FullConditionDescription=tbll.FullConditionDescription
		FROM LeagueManagementSetting AS setting WITH (NOLOCK)
			INNER JOIN OWPLeague AS owpl WITH (NOLOCK) ON setting.OWPLeagueId=owpl.OWPLeagueId
			INNER JOIN #tblLeague AS tbll WITH (NOLOCK) ON owpl.OWPLeagueName=tbll.League
    END;