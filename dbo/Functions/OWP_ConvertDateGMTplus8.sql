/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="1"></info>*/
CREATE FUNCTION [dbo].[OWP_ConvertDateGMTplus8]
(
	@date DATETIME
)
RETURNS DATETIME
AS
/*
Created: 20161101@Simon.Huynh
Task : convert datetime to gmt+8
DB: bodb_OWP

Revisions:
	20181009@Raymond.Le: new structure
 
*/
BEGIN
	RETURN DATEADD(HOUR,12,@date)
END