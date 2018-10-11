CREATE TABLE [dbo].[Agent] (
    [AgentId]   INT            IDENTITY (1, 1) NOT NULL,
    [AgentName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Agent] PRIMARY KEY CLUSTERED ([AgentId] ASC)
);

