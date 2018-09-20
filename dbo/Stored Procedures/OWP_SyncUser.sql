/****** Object:  Stored Procedure dbo.OWP_SyncUser    Script Date: 4/13/2018 4:05:27 PM ******/


CREATE PROCEDURE [dbo].[OWP_SyncUser] 
    @User xml
AS
/*
Created: 20180413@Jacob.Phan
Task: Sync Table UserRole in database bodb_OWP to database bodb_OWP_Test
DB: bodb_OWP_Test
Original: 

Revisions:
*/
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE [bodb_OWP_Test].[dbo].[User];

    INSERT INTO [bodb_OWP_Test].[dbo].[User]( [UserId], 
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
           )
           SELECT T.C.value('@UserId', 'int'), 
                  T.C.value('@FullName', 'nvarchar(200)'), 
                  T.C.value('@ProfilePic', 'varchar(500)'), 
                  T.C.value('@Username', 'varchar(50)'), 
                  T.C.value('@Nickname', 'varchar(30)'), 
                  T.C.value('@EmployeeId', 'varchar(30)'), 
                  T.C.value('@Skype', 'varchar(50)'), 
                  T.C.value('@DepartmentId', 'smallint'), 
                  T.C.value('@SectionId', 'smallint'), 
                  T.C.value('@Extension', 'varchar(30)'), 
                  T.C.value('@Phone', 'varchar(30)'), 
                  T.C.value('@Email', 'varchar(50)'), 
                  T.C.value('@LocationCode', 'varchar(10)'), 
                  T.C.value('@CategoryId', 'smallint')
           FROM @User.nodes('dbo.User') AS T(C);
END;