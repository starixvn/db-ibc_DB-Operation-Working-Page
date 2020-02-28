
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/


ALTER PROCEDURE [dbo].[Task_OWP_CleanOldData]
AS

/*
	Created: Jacob
	Date: 2020-02-28
	Task: Clean Old Data
	DB: DBOWP/bodb_OWP
Revisions:
- 20200228@Jacob: Clean Old Data - [Redmine: #129435]
Remarks:
- Delete data before 1 year ago of table: [UserLog]
- Delete data before 6 months ago of table: [MessageUser], [Message]
*/

SET NOCOUNT ON;
DECLARE @YearAgo DATETIME= DATEADD(YEAR, -1, CONVERT(DATE, GETDATE()));
DECLARE @SixMonthsAgo DATETIME= DATEADD(MONTH, -6, CONVERT(DATE, GETDATE()));
DECLARE @TempDate DATETIME;

-- @MinDateOfUserLog
DECLARE @MinDateOfUserLog DATETIME;
SELECT @MinDateOfUserLog = MIN(LoggedDate)
FROM [UserLog] WITH(NOLOCK);

--//delete [UserLog]
SELECT @TempDate = @MinDateOfUserLog;
WHILE @TempDate < @YearAgo
BEGIN
    DELETE TOP (3000) dbo.[UserLog] WITH(ROWLOCK)
    WHERE LoggedDate >= @TempDate AND LoggedDate < DATEADD(DAY, 1, @TempDate);

    IF @@ROWCOUNT = 0
        SELECT @TempDate = DATEADD(DAY, 1, @TempDate);
    ELSE
        PRINT '3000 rows of [UserLog] at ' + CONVERT(VARCHAR(50), @TempDate) + ' was deleted. Now is ' + CONVERT(VARCHAR(50), GETDATE());
END;

--// delete messageuser & message
DECLARE @MinDateOfMessage DATETIME;
SELECT @MinDateOfMessage = MIN(CreatedDate)
FROM [Message] WITH(NOLOCK);
DECLARE @__messages TABLE(messageId INT);
DECLARE @__messagesTemp TABLE
(messageId INT
 PRIMARY KEY
);

SELECT @TempDate = @MinDateOfMessage;
WHILE @TempDate < @SixMonthsAgo
BEGIN
	
	DELETE FROM @__messages;
	INSERT INTO @__messages(messageId)
    SELECT messageId
    FROM [Message] m WITH(NOLOCK)
    WHERE CreatedDate >= @TempDate
            AND CreatedDate < DATEADD(DAY, 1, @TempDate);
	
	WHILE 1 = 1
	BEGIN
		DELETE FROM @__messagesTemp;
		DELETE TOP (3000)
		FROM @__messages
		OUTPUT DELETED.messageId
		INTO @__messagesTemp(messageId);

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT @TempDate = DATEADD(DAY, 1, @TempDate);
			PRINT '3000 rows of [MessageUser] at ' + CONVERT(VARCHAR(50), @TempDate) + ' was deleted. Now is ' + CONVERT(VARCHAR(50), GETDATE());
			BREAK;
		END

		do_more_usermessage:
		DELETE TOP(3000) mu
		FROM dbo.[MessageUser] mu WITH(ROWLOCK)
		WHERE EXISTS (SELECT TOP 1 1 FROM @__messagesTemp t WHERE mu.MessageId = t.messageId);

		IF @@ROWCOUNT > 0
			GOTO do_more_usermessage;

		DELETE m
		FROM dbo.[Message] m WITH(ROWLOCK)
		WHERE EXISTS (SELECT TOP 1 1 FROM @__messagesTemp t WHERE m.MessageId = t.messageId);
	END	
	
END;