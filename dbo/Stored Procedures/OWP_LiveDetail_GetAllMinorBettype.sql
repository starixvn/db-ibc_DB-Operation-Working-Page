CREATE PROCEDURE [dbo].[OWP_LiveDetail_GetAllMinorBettype] @OWPMatchId INT
AS
/*
Created: 2017-03-16@Raymond.Le
Task : Get Minor bettype
DB: bodb_OWP
*/
BEGIN
	SET NOCOUNT ON

	SELECT mb.MinorBettypeId
		,mb.MinorBettypeName
		,mm.IsExist
	FROM dbo.MinorBettype AS mb WITH (NOLOCK)
		LEFT JOIN (
		SELECT DISTINCT ParentMatchId
			,MinorBettypeId
			,1 AS IsExist
		FROM dbo.MinorMatch WITH (NOLOCK)
		WHERE ParentMatchId = @OWPMatchId
			AND IsRepresented = 1
		) AS mm ON mb.MinorBettypeId = mm.MinorBettypeId
	WHERE mb.ParentBettypeId IS NULL
		AND mb.IsActive = 1
		AND mb.IsMinorBettype = 1
	ORDER BY (CASE 
			WHEN mb.MinorBettypeId = - 5 THEN - 3
			WHEN mb.MinorBettypeId = - 8 THEN - 6
			ELSE mb.MinorBettypeId END
			) DESC
		,mb.MinorBettypeId DESC
END