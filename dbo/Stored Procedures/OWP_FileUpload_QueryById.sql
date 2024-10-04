
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_FileUpload_QueryById] @FileId INT
AS

/*
Created: 20201201@Tyler
Task : File upload
DB: bodb_OWP

Revisions:
	20201201@Tyler: file upload  - [Redmine: #145591]
	20230802@Mira: remove save binary file  - [Redmine: #191543]
	20241002@Mira: join with File Upload Old [Redmine: #211716]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT [FileId], 
               [Title], 
               [SavedFileName]
        FROM [bodb_OWP].[dbo].[FileUpload] WITH(NOLOCK)
        WHERE [FileId] = @FileId
        UNION
        SELECT [FileId], 
               [Title], 
               [SavedFileName]
        FROM [bodb_OWP].[dbo].[FileUpload_Old] WITH(NOLOCK)
        WHERE [FileId] = @FileId;
    END;