CREATE PROCEDURE [dbo].[DBA_GrantPermissions] 
            @SPs			nvarchar(4000), 
            @strPermission	varchar(4000)='' OUTPUT 
            AS 
             BEGIN 
             SET NOCOUNT ON; 
            DECLARE @SP_name nvarchar(4000), @i int, @StringPermission nvarchar(4000) 
             SELECT @SPs = @SPs + ',' , @strPermission ='GO nnn' 
             SELECT @SPs = replace(@SPs, ',,', ',') 
             SELECT @i = charindex(',', @SPs) 
             WHILE @i > 0 
            BEGIN 
             SELECT @SP_name = left(@SPs, @I-1) 
             SELECT @SPs = replace(@SPs, @SP_name + ',', '') 
             SELECT @strPermission = @strPermission + ' ' + state_desc + ' '+ permission_name + ' ON ' +  '[dbo].[' + OBJECT_NAME(major_id)  + ']' + ' TO '+ '['+ USER_NAME(grantee_principal_id)+']' + 'nnnGO nnn' 
             FROM sys.database_permissions 
            WHERE OBJECT_NAME(major_id)= @SP_Name 
            SELECT @i = charindex(',', @SPs) 
            END 
            Select @strPermission 
            END