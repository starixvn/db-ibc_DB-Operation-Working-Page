
-- init data NoOfHDP in table RefResource
INSERT INTO dbo.RefResource(RefName, ResourceId, [Value])
VALUES ('NoOfHDP', 1, '1HDP'), ('NoOfHDP', 2, '2HDP'), ('NoOfHDP', 3, '3HDP'), ('NoOfHDP', 4, '4DHP') 

-- change rule
UPDATE dbo.ValidationRule
SET MessageFormat = 'Invalid NO.HDP: <content>'
WHERE RuleId = 28