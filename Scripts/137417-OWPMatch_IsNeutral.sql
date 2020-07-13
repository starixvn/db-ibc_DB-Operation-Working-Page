/*
Created: 20200710@Esther
Task : Event Upload- Importing match in Neutral Stadium (N)
DB: bodb_OWP	

Revisions:
	20200710@Esther: New structure of Event Upload - [Redmine: #137417]
*/

ALTER TABLE OWPMatch 
ADD IsNeutral BIT NOT NULL
CONSTRAINT DF_OWPMatch_IsNeutral DEFAULT 0
WITH VALUES

ALTER TABLE InfositeMatch 
ADD IsNeutral BIT NOT NULL
CONSTRAINT DF_InfositeMatch_IsNeutral DEFAULT 0
WITH VALUES

