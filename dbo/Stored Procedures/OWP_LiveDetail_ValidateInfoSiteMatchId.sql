-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OWP_LiveDetail_ValidateInfoSiteMatchId]
	-- Add the parameters for the stored procedure here
	@InfoSiteMatchId INT
AS
/*
Created: 20190820@Tyler.Dang
Task : Validate InfoSiteMatchId is existed or not
DB: bodb_OWP
*/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Valid BIT
    -- Insert statements for procedure here
	IF EXISTS (SELECT * FROM InfoSiteMatch WHERE InfoSiteMatchId = @InfoSiteMatchId)
		SET @Valid = 1;
	ELSE
		SET @Valid = 0;

	SELECT @Valid AS IsValid;
END