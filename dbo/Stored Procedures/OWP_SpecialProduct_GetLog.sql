
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_GetLog]
	@ObjectId INT,
	@PageSize INT
AS
/*      
 Created: 20180617@carlos.nguyen 
 Task : Get log
 DB: bodb_OWP      
 
 Revisions:
    20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @tblSpecialProductLogAction TABLE (
		ActionId INT PRIMARY KEY
	)
	
	INSERT INTO @tblSpecialProductLogAction (ActionId)
	VALUES (109), (110), (111)

	SELECT TOP (@PageSize)
		ul.LoggedDate AS ModifiedDate
		,u.Username  AS ModifiedBy
		,lat.ActionTypeName AS [Action]
		,ul.DataOld
		,ul.Data
	FROM dbo.UserLog AS ul WITH (NOLOCK)
	INNER JOIN @tblSpecialProductLogAction AS sp ON ul.ActionId = sp.ActionId
	LEFT JOIN dbo.[User] AS u WITH (NOLOCK) ON ul.CreatorId = u.UserId
	LEFT JOIN LogAction AS la WITH (NOLOCK) on la.ActionId=ul.ActionId
	LEFT JOIN LogActionType AS lat WITH (NOLOCK) ON lat.ActionTypeId=la.ActionTypeId
	WHERE ul.ObjectId = @ObjectId
	ORDER BY ul.LoggedDate DESC
END;