CREATE PROCEDURE [dbo].[OWP_TelevisionGetAll]
AS	
	/*
	Created: 2016-10-06@Aaron
	Task : Get all TVs
	DB: bodb_OWP

	Revisions:   
	*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	 t.TVCode
			,t.TVName
			,t.Decoder
			,t.Country
	FROM dbo.Television t WITH (NOLOCK)
	WHERE t.IsActive = 1
END