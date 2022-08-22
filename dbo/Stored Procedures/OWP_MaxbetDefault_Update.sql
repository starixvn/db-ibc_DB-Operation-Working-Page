
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_MaxbetSetting_Update] @FT_HDP VARCHAR(MAX), 
                                                 @Column VARCHAR(200), 
                                                 @Value  VARCHAR(MAX)
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
        DECLARE @sqlCommand VARCHAR(1000);

        -- Update
        SET @sqlCommand = 'UPDATE dbo.MaxbetSetting SET ' + @Column + ' = ' + @Value + 'WHERE FT_HDP = ' + @FT_HDP;
        EXEC (@sqlCommand);
    END;