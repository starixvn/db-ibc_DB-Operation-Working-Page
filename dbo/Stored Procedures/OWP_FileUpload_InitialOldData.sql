
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_FileUpload_InitialOldData]
AS

/*
Created: 20230802@Mira
Task : File upload
DB: bodb_OWP

Revisions:
	20230802@Mira: initial old data  - [Redmine: #191543]
*/

    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.FileUpload
          SET 
              SavedFileName = CONCAT(CAST(FileId AS NVARCHAR(200)), '_', Title)
        OUTPUT INSERTED.FileContent, 
               INSERTED.SavedFileName
        WHERE FileContent IS NOT NULL;
    END;