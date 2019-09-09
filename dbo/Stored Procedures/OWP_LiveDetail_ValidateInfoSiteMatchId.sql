/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
CREATE PROCEDURE [dbo].[OWP_LiveDetail_ValidateInfoSiteMatchId]
	-- Add the parameters for the stored procedure here
	@InfoSiteMatchId INT
AS
/*
Created: 20190820@Tyler.Dang
Task : Validate InfoSiteMatchId is existed or not
DB: bodb_OWP

Revisions:
	20190820@Tyler.Dang: InitialSP - [Redmine: #118566]
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Valid BIT
    -- Insert statements for procedure here
	IF EXISTS (SELECT 1 FROM InfoSiteMatch WITH (NOLOCK) WHERE InfoSiteMatchId = @InfoSiteMatchId)
		SET @Valid = 1;
	ELSE
		SET @Valid = 0;

	SELECT @Valid AS IsValid;
END