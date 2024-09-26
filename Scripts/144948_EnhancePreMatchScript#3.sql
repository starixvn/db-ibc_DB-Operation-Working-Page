
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20201110@Tyler
Task : Pre-Match enhancement 32
DB: bodb_OWP	

Revisions:
	20201110@Tyler: remove other assignment note - [Redmine: #144948]
*/

ALTER TABLE dbo.[PreMatchAssignment]
DROP COLUMN AssignmentNote;

UPDATE dbo.[LogAction]
  SET 
      LogItems = N'<root><xml path="r/z" /><row item="PreMatchLeagueId" alias="plid" /><row item="UserId" alias="uid" /><row item="Username" alias="un" /><row item="Bettype" alias="bt" /><row item="IsTakeOver" alias="ito" /><row item="AssignmentType" alias="at" /></root>'
WHERE ActionId = 113;

DELETE r
FROM dbo.[LogAction] r
WHERE ActionId = 119
      AND ActionName = N'OWPPreMatchAssignmentUpdateOtherAssignment';

DROP PROCEDURE OWP_PreMatchAssignment_DeleteOtherAssignment;  
DROP PROCEDURE OWP_PreMatchAssignment_InsertOtherAssignment;  
DROP PROCEDURE OWP_PreMatchAssignment_InsertUpdateDeleteOtherAssignment;  
DROP PROCEDURE OWP_PreMatchAssignment_QueryOtherAssignment;  
DROP PROCEDURE OWP_PreMatchAssignment_UpdateOtherAssignment;  
DROP PROCEDURE OWP_PreMatchAssignment_UpdateOtherAssignmentNote;  
