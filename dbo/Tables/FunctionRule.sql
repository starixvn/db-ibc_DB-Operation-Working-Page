CREATE TABLE [dbo].[FunctionRule] (
    [FunctionId] SMALLINT NOT NULL,
    [RuleId]     SMALLINT NOT NULL,
    [Order]      SMALLINT NULL,
    CONSTRAINT [PK_FunctionRule] PRIMARY KEY CLUSTERED ([FunctionId] ASC, [RuleId] ASC) ON [PRIMARY]
);

