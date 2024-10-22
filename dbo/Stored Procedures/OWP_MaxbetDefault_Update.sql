
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MaxbetSetting_Update] @FT_HDP  VARCHAR(MAX), 
                                                 @Column  VARCHAR(200), 
                                                 @Value   VARCHAR(MAX) = NULL, 
                                                 @ActorId INT
WITH EXECUTE AS OWNER
AS

/*    
Created: 20220822@Mira
Task : Soccer Maxbet setting
DB: bodb_OWP

Revisions:
	20220822@Mira: SP for update maxbet default value - [Redmine: #176781]
*/

    BEGIN
        SET NOCOUNT ON;
        DECLARE @sqlCommand NVARCHAR(MAX), @OldValue NVARCHAR(MAX);
        DECLARE @StartRun DATETIME, @EndRun DATETIME, @Duration INT, @NewXml XML, @OldXml XML;
        DECLARE @CharValue NVARCHAR(MAX)= ISNULL(CONVERT(NVARCHAR(MAX), @Value), '');

        -- For write old log
        SET @StartRun = GETDATE();
        SET @sqlCommand = N'SELECT ' + '@oldValue = ' + @Column + ' FROM dbo.MaxbetSetting WHERE FT_HDP = ' + @FT_HDP;
        EXEC sp_executesql 
             @sqlCommand, 
             N'@oldValue VARCHAR(MAX) OUTPUT', 
             @oldValue = @OldValue OUTPUT;
        SET @sqlCommand = N'SET ' + '@xml = (SELECT ''' + ISNULL(CONVERT(NVARCHAR(MAX), @OldValue), '') + ''' AS "@' + @Column + '" FOR XML PATH(''z''),ROOT(''r''))';
        EXEC sp_executesql 
             @sqlCommand, 
             N'@xml xml OUTPUT', 
             @xml = @OldXml OUTPUT;

        -- Update
        SET @sqlCommand = 'UPDATE dbo.MaxbetSetting SET ' + @Column + ' = ' + ISNULL(CONVERT(NVARCHAR(MAX), @Value), 'Null') + ' WHERE FT_HDP = ' + @FT_HDP;
        EXEC (@sqlCommand);

        -- Write new log
        SET @sqlCommand = N'SET ' + '@xml = (SELECT ''' + ISNULL(CONVERT(NVARCHAR(MAX), @Value), '') + ''' AS "@' + @Column + '" FOR XML PATH(''z''),ROOT(''r''))';
        EXEC sp_executesql 
             @sqlCommand, 
             N'@xml xml OUTPUT', 
             @xml = @NewXml OUTPUT;
        SET @EndRun = GETDATE();
        SET @Duration = DATEDIFF(MILLISECOND, @StartRun, @EndRun);

        -- convert xml to nvarchar
        DECLARE @LogOldData NVARCHAR(MAX)= REPLACE(CONVERT(NVARCHAR(MAX), @OldXml), '" />', '"/"');
        DECLARE @LogNewData NVARCHAR(MAX)= REPLACE(CONVERT(NVARCHAR(MAX), @NewXml), '" />', '"/"');

        -- exec write log
        EXEC dbo.OWP_WriteLog 
             @CreatorId = @ActorId, 
             @SPName = 'OWP_MaxbetSetting_Update', 
             @LoggedDate = @StartRun, 
             @Duration = @Duration, 
             @ObjectId = @FT_HDP, 
             @Data = @LogNewData, 
             @DataOld = @LogOldData;
    END;