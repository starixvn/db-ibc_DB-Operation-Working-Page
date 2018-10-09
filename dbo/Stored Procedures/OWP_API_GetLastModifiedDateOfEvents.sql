/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_API_GetLastModifiedDateOfEvents]
AS
/*    
 Created: 20170123@Quinn.Vo
 Task : Get last modified date of events which changed from info site.
 DB: bodb_OWP
    
 Revisions:
	20181009@Raymond.Le: new structure
*/
BEGIN
	SET NOCOUNT ON

	SELECT CAST(rr.VALUE AS DATETIME)
	FROM dbo.RefResource rr WITH (NOLOCK)
	WHERE rr.RefName = 'LastModifiedDateEvents'
END