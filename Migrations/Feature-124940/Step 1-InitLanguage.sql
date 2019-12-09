
/*
	Created: Carlos.Nguyen
	Date: 201910512
	Task:  Add column (Language) [Redmine: #125019]
	DB: bodb_OWP
*/
USE bodb_OWP;
GO

INSERT INTO RefResource(RefName,ResourceId,Value,[Order])
VALUES('Language', 1, 'CN',0),
	  ('Language', 2, 'EN',0),
	  ('Language', 3, 'VN',0)