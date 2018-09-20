-- =============================================
-- Author:		Simon.Huynh
-- Create date: 20161101
-- =============================================
CREATE FUNCTION [dbo].[OWP_ConvertDateGMT+8]
(
	@date DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(HOUR,12,@date)
END