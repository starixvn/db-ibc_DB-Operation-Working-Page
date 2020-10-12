/*
	Created: Leo.Vo
	Date: 20190521
	Task: [Redmine: #113763]
	DB: bodb_OWP
*/

--------------------------------
-- 1. Alter schema
--------------------------------
USE bodb_OWP

ALTER TABLE dbo.LogAction
ALTER COLUMN SPName NVARCHAR(128)

CREATE UNIQUE NONCLUSTERED INDEX [IX_Username]
    ON [dbo].[User]([Username] ASC)
    ON [OWP_Index];
	
DROP INDEX [IX_Nickname] ON [dbo].[User]

CREATE UNIQUE NONCLUSTERED INDEX [IX_Nickname] ON [dbo].[User] ([Nickname] ASC)
WHERE Nickname IS NOT NULL
ON [OWP_Index]

GO