/****** Object:  Stored Procedure dbo.OWP_SyncUserRole    Script Date: 4/13/2018 4:05:27 PM ******/


CREATE PROCEDURE [dbo].[OWP_SyncUserRole] @UserRole XML
AS
/*
Created: 20180413@Jacob.Phan
Task: Sync Table UserRole in database bodb_OWP to database bodb_OWP_Test
DB: bodb_OWP_Test
Original: 

Revisions:
*/

BEGIN
	SET NOCOUNT ON

	TRUNCATE TABLE [bodb_OWP_Test].[dbo].[UserRole]

	INSERT INTO [bodb_OWP_Test].[dbo].[UserRole](UserId, RoleId)
	SELECT  T.C.value('@UserId', 'INT'), 
                   T.C.value('@RoleId', 'INT')
           FROM @UserRole.nodes('dbo.UserRole') AS T(C);
END