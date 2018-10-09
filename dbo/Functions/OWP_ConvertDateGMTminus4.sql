/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_ConvertDateGMTminus4]
(
	@Date DATE,
	@Time TIME
)
RETURNS DATETIME
AS
/*
Created: 20161101@Simon.Huynh
Task : convert datetime to gmt-4
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
 
*/
BEGIN
	DECLARE @DateTime DATETIME = CAST(@Date AS DATETIME) + CAST(@Time AS DATETIME)

	RETURN DATEADD(hh,-12,@DateTime)
END