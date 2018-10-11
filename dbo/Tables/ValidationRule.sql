CREATE TABLE [dbo].[ValidationRule] (
    [RuleId]         SMALLINT       IDENTITY (1, 1) NOT NULL,
    [RuleName]       NVARCHAR (50)  NOT NULL,
    [Description]    NVARCHAR (200) NULL,
    [IsActive]       BIT            CONSTRAINT [DF_ValidationRule_IsActive] DEFAULT ((1)) NOT NULL,
    [RuleResultType] SMALLINT       NOT NULL,
    [Category]       SMALLINT       NOT NULL,
    [MessageFormat]  NVARCHAR (200) NULL,
    [SPName]         VARCHAR (200)  NULL,
    CONSTRAINT [PK_ValidationRule] PRIMARY KEY CLUSTERED ([RuleId] ASC) ON [PRIMARY]
);



