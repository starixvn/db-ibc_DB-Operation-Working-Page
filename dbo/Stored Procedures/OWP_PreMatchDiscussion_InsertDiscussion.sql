/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[OWP_PreMatchDiscussion_InsertDiscussion] 
    @ActorId INT,
    @AdminSiteMatchId INT,
    @IsIncludeTrader BIT,
    @DiscussionInfoXML XML
AS
/*  
Created: 20251105@Hank  
Task : Insert pre-match discussion with multiple discussion info items
DB: bodb_OWP  
  
Revisions:  
    20251105@Hank: Insert discussion info using XML parameter - [Redmine: #240618]
*/
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @DiscussionId INT;
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @idoc INT;
    
    -- Insert into PreMatchDiscussion main table
    INSERT INTO [dbo].[PreMatchDiscussion] 
    (
        IsIncludeTrader,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy
    )
    VALUES 
    (
        @IsIncludeTrader,
        @CurrentDate,
        @ActorId,
        @CurrentDate,
        @ActorId
    );
    
    -- Get the newly created DiscussionId
    SET @DiscussionId = SCOPE_IDENTITY();
    
    -- Parse XML data
    EXEC sp_xml_preparedocument 
         @idoc OUTPUT, 
         @DiscussionInfoXML;
    
    -- Insert into PreMatchDiscussionInfo from XML
    INSERT INTO [dbo].[PreMatchDiscussionInfo]
    (
        DiscussionId,
        AdminSiteMatchId,
        BetType,
        RCDiscussionGroupId,
        BetOn,
        HomeId,
        AwayId,
        GhostName,
        GhostDetail,
        HdpOu,
        Odds,
        Note,
        Remark
    )
    SELECT 
        @DiscussionId,
        @AdminSiteMatchId,
        BetType,
        RCDiscussionGroupId,
        BetOn,
        HomeId,
        AwayId,
        GhostName,
        GhostDetail,
        HdpOu,
        Odds,
        Note,
        Remark
    FROM OPENXML(@idoc, '/Root/DiscussionInfo', 1) 
    WITH (
        BetType INT,
        RCDiscussionGroupId NVARCHAR(255),
        BetOn NVARCHAR(100),
        HomeId INT,
        AwayId INT,
        GhostName NVARCHAR(100),
        GhostDetail NVARCHAR(2000),
        HdpOu MONEY,
        Odds NVARCHAR(255),
        Note NVARCHAR(MAX),
        Remark NVARCHAR(MAX)
    );
    
    -- Clean up XML document
    EXEC sp_xml_removedocument @idoc;
END
