/****** Object:  Stored Procedure dbo.OWP_GetForSyncUser    Script Date: 4/13/2018 4:05:27 PM ******/


CREATE PROCEDURE [dbo].[OWP_GetForSyncUser]
AS
/*
Created: 20180413@Jacob.Phan
Task: Sync Table User in database bodb_OWP to database bodb_OWP_Test
DB: bodb_OWP
Original: 

Revisions:
*/

BEGIN
    SELECT [UserId], 
           [FullName], 
           [ProfilePic], 
           [Username], 
           [Nickname], 
           [EmployeeId], 
           [Skype], 
           [DepartmentId], 
           [SectionId], 
           [Extension], 
           [Phone], 
           [Email], 
           [LocationCode], 
           [CategoryId]
    FROM [dbo].[User] WITH(NOLOCK) FOR XML AUTO, TYPE;
END;