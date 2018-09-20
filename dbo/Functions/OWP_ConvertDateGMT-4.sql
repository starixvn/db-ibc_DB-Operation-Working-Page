/****** Object:  User Defined Function dbo.OWP_ConvertDateGMT-4    Script Date: 11/11/2016 2:21:30 PM ******/
-- =============================================
-- Author:		Simon Huynh
-- Create date: 20161101
-- =============================================
CREATE FUNCTION [dbo].[OWP_ConvertDateGMT-4]
(
	@Date DATE,
	@Time TIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @DateTime DATETIME = CAST(@Date AS DATETIME) + CAST(@Time AS DATETIME)

	RETURN DATEADD(hh,-12,@DateTime)
END