/*
	Created: Leo.Vo
	Date: 20190717
	Task: [Redmine: #117098]
	DB: bodb_OWP
*/
USE bodb_OWP

ALTER TABLE dbo.RefResource
ADD [Order]     SMALLINT  CONSTRAINT [DF_RefResource_Order] DEFAULT (0) NOT NULL

GO