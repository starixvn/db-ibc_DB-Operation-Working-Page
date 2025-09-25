
/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

ALTER PROCEDURE [dbo].[OWP_LeagueManagement_InsertLog] @SettingId			INT, 
                                                          @ModifiedBy       VARCHAR(255), 
														  @CreatedDate		DATETIME,
														  @Action			VARCHAR(255), 
														  @Field			VARCHAR(255),
														  @OldValue			VARCHAR(MAX),
														  @NewValue			VARCHAR(MAX)
AS

/*      
 Created: 20250924@Frankie
 Task : view history log league management
 DB: bodb_OWP      
 
 Revisions:
    20520924@Frankie: Init SP insert log - [Redmine: #236027]
*/

BEGIN
    SET NOCOUNT ON;

    INSERT INTO [LeagueSettingLog]
        ([CreatedDate], 
            [ModifiedBy], 
            [SettingId], 
            [Action], 
            [Field],
            [OldValue],
            [NewValue]
        )
    VALUES 
        (@CreatedDate,
            @ModifiedBy,
            @SettingId,
            @Action,
            @Field,
            @OldValue,
            @NewValue
        )
END;