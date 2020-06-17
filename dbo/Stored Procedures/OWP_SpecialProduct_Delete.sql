/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_SpecialProduct_Delete]
	@ProductId INT
AS
/*
Created: 20180617@Carlos.Nguyen
Task : delete Special Product
DB: bodb_OWP

Revisions:
	20180617@Carlos.Nguyen: Init sp - [Redmine: #134338]
*/

BEGIN
	SET NOCOUNT ON
	
	DELETE FROM SpecialProduct
	WHERE ProductId=@ProductId

END